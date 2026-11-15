from __future__ import annotations
from typing import Optional
import os
import secrets
from datetime import datetime, timezone
from uuid import uuid4

from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel, Field, SecretStr, model_validator

from .db import (
    init_db,
    create_job,
    get_job,
    get_job_for_service,
    create_management_operation,
    get_management_operation,
    get_latest_management_operation,
    has_active_management_operation,
)
from .profiles import get_profile
from .secrets import write_secret, delete_secret


app = FastAPI(
    title="DataHoteling Provisioning API",
    version="0.2.0",
)


API_TOKEN = os.getenv("DATAHOTELING_PROVISIONING_API_TOKEN")

if not API_TOKEN:
    raise RuntimeError(
        "DATAHOTELING_PROVISIONING_API_TOKEN must be set"
    )


class PasswordChangeRequest(BaseModel):
    new_password: SecretStr = Field(
        min_length=8,
        max_length=128,
        description="New customer login password",
    )


class ReinstallRequest(BaseModel):
    new_password: SecretStr = Field(
        min_length=8,
        max_length=128,
        description="New customer login password",
    )


class ProvisionRequest(BaseModel):
    service_id: int = Field(
        gt=0,
        description="WHMCS service ID",
    )

    package: str = Field(
        min_length=1,
        max_length=64,
        pattern=r"^vps-(basic|standard|pro)$",
        description="Supported VPS package",
    )

    hostname: str = Field(
        min_length=1,
        max_length=63,
        pattern=r"^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$",
        description="Single-label lowercase Linux hostname",
    )

    customer_username: str = Field(
        min_length=1,
        max_length=32,
        pattern=r"^[a-z_][a-z0-9_-]*$",
        description="Linux customer username",
    )

    customer_password: SecretStr = Field(
        min_length=8,
        max_length=128,
        description="Customer login password",
    )

    # Optional VPS configurator fields.
    # If one is provided, all four must be provided.
    os_type: Optional[str] = Field(
        default=None,
        pattern=r"^ubuntu-24\.04$",
        description="Operating system identifier",
    )

    num_cpus: Optional[int] = Field(
        default=None,
        ge=1,
        le=32,
        description="Number of vCPU cores",
    )

    memory_mb: Optional[int] = Field(
        default=None,
        ge=1024,
        le=131072,
        description="RAM in MB",
    )

    disk_size_gb: Optional[int] = Field(
        default=None,
        ge=10,
        le=1000,
        description="Disk size in GB",
    )

    @model_validator(mode="after")
    def validate_custom_config(self):
        config_fields = (
            self.os_type,
            self.num_cpus,
            self.memory_mb,
            self.disk_size_gb,
        )

        provided = [value is not None for value in config_fields]

        if any(provided) and not all(provided):
            raise ValueError(
                "os_type, num_cpus, memory_mb, and disk_size_gb "
                "must all be provided together"
            )

        return self


def check_auth(authorization: Optional[str]):
    expected = f"Bearer {API_TOKEN}"

    if not authorization or not secrets.compare_digest(
        authorization,
        expected,
    ):
        raise HTTPException(
            status_code=401,
            detail="Unauthorized",
        )


@app.on_event("startup")
def startup():
    init_db()





def create_power_operation(service_id: int, operation: str):
    """
    Create a queued VPS power-management operation.

    This endpoint only creates a durable queue record.
    No vCenter operation is executed here.
    """
    if operation not in {"on", "shutdown", "restart"}:
        raise HTTPException(
            status_code=400,
            detail="Unsupported power operation",
        )

    if has_active_management_operation(service_id):
        raise HTTPException(
            status_code=409,
            detail="A management operation is already active for this service",
        )

    now = datetime.now(timezone.utc).isoformat()
    operation_id = str(uuid4())

    management_operation = {
        "operation_id": operation_id,
        "service_id": service_id,
        "operation": f"power_{operation}",
        "status": "queued",
        "created_at": now,
        "updated_at": now,
    }

    try:
        create_management_operation(management_operation)
    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Failed to create management operation",
        )

    return {
        "operation_id": operation_id,
        "service_id": service_id,
        "operation": f"power_{operation}",
        "status": "queued",
    }



@app.post("/v1/vps/{service_id}/password")
def change_vps_password(
    service_id: int,
    request: PasswordChangeRequest,
    authorization: str = Header(default=""),
):
    check_auth(authorization)

    customer_password = request.new_password.get_secret_value()

    if has_active_management_operation(service_id):
        raise HTTPException(
            status_code=409,
            detail="Another VPS management operation is already active",
        )

    now = datetime.now(timezone.utc).isoformat()
    operation_id = str(uuid4())

    management_operation = {
        "operation_id": operation_id,
        "service_id": service_id,
        "operation": "change_password",
        "status": "queued",
        "created_at": now,
        "updated_at": now,
    }

    try:
        write_secret(operation_id, customer_password)
        create_management_operation(management_operation)

    except Exception:
        delete_secret(operation_id)
        raise

    return {
        "operation_id": operation_id,
        "service_id": service_id,
        "operation": "change_password",
        "status": "queued",
    }


@app.post("/v1/vps/{service_id}/reinstall")
def reinstall_vps(
    service_id: int,
    request: ReinstallRequest,
    authorization: Optional[str] = Header(default=None),
):
    check_auth(authorization)

    if service_id <= 0:
        raise HTTPException(
            status_code=400,
            detail="Invalid service ID",
        )

    if has_active_management_operation(service_id):
        raise HTTPException(
            status_code=409,
            detail="Another VPS management operation is already active",
        )

    job = get_job_for_service(service_id)

    if job is None:
        raise HTTPException(
            status_code=404,
            detail="VPS service not found",
        )

    customer_password = request.new_password.get_secret_value()

    now = datetime.now(timezone.utc).isoformat()
    operation_id = str(uuid4())

    management_operation = {
        "operation_id": operation_id,
        "service_id": service_id,
        "operation": "reinstall",
        "status": "queued",
        "created_at": now,
        "updated_at": now,
    }

    try:
        write_secret(
            operation_id,
            customer_password,
        )

        create_management_operation(
            management_operation
        )

    except Exception:
        delete_secret(operation_id)
        raise

    return {
        "operation_id": operation_id,
        "service_id": service_id,
        "operation": "reinstall",
        "status": "queued",
    }


@app.post("/v1/vps/{service_id}/power/on")
def power_on(
    service_id: int,
    authorization: Optional[str] = Header(default=None),
):
    check_auth(authorization)

    if service_id <= 0:
        raise HTTPException(
            status_code=400,
            detail="Invalid service ID",
        )

    return create_power_operation(service_id, "on")


@app.post("/v1/vps/{service_id}/power/shutdown")
def power_shutdown(
    service_id: int,
    authorization: Optional[str] = Header(default=None),
):
    check_auth(authorization)

    if service_id <= 0:
        raise HTTPException(
            status_code=400,
            detail="Invalid service ID",
        )

    return create_power_operation(service_id, "shutdown")


@app.post("/v1/vps/{service_id}/power/restart")
def power_restart(
    service_id: int,
    authorization: Optional[str] = Header(default=None),
):
    check_auth(authorization)

    if service_id <= 0:
        raise HTTPException(
            status_code=400,
            detail="Invalid service ID",
        )

    return create_power_operation(service_id, "restart")


@app.get("/v1/vps/{service_id}/operations/{operation_id}")
def get_vps_operation(
    service_id: int,
    operation_id: str,
    authorization: Optional[str] = Header(default=None),
):
    check_auth(authorization)

    if service_id <= 0:
        raise HTTPException(
            status_code=400,
            detail="Invalid service ID",
        )

    operation = get_management_operation(operation_id)

    if operation is None:
        raise HTTPException(
            status_code=404,
            detail="Management operation not found",
        )

    if int(operation["service_id"]) != service_id:
        raise HTTPException(
            status_code=404,
            detail="Management operation not found",
        )

    return operation


@app.get("/v1/vps/{service_id}/operations/latest")
def get_latest_vps_operation(
    service_id: int,
    authorization: Optional[str] = Header(default=None),
):
    check_auth(authorization)

    if service_id <= 0:
        raise HTTPException(
            status_code=400,
            detail="Invalid service ID",
        )

    operation = get_latest_management_operation(service_id)

    if operation is None:
        raise HTTPException(
            status_code=404,
            detail="No management operation found",
        )

    return operation


@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "datahoteling-provisioning-api",
        "version": "0.2.0",
    }


@app.post("/v1/provision")
def provision(
    request: ProvisionRequest,
    authorization: Optional[str] = Header(default=None),
):
    check_auth(authorization)

    profile = get_profile(request.package)

    if profile is None:
        raise HTTPException(
            status_code=400,
            detail=f"Unknown package: {request.package}",
        )

    now = datetime.now(timezone.utc).isoformat()
    job_id = str(uuid4())

    job = {
        "job_id": job_id,
        "service_id": request.service_id,
        "package": request.package,
        "hostname": request.hostname,
        "customer_username": request.customer_username,
        "status": "queued",
        "vm_ip": None,
        "error": None,
        "created_at": now,
        "updated_at": now,
        "os_type": request.os_type,
        "num_cpus": request.num_cpus,
        "memory_mb": request.memory_mb,
        "disk_size_gb": request.disk_size_gb,
    }

    password = request.customer_password.get_secret_value()

    secret_created = False

    try:
        write_secret(job_id, password)
        secret_created = True

        stored_job, created = create_job(job)

        # Idempotent retry: an existing service already owns the job.
        # Never replace its existing password with a new one.
        if not created:
            delete_secret(job_id)
            secret_created = False

        response = {
            **stored_job,
            "profile": profile,
            "created": created,
        }

        return response

    except Exception:
        if secret_created:
            delete_secret(job_id)
        raise


@app.get("/v1/jobs/{job_id}")
def get_job_status(
    job_id: str,
    authorization: Optional[str] = Header(default=None),
):
    check_auth(authorization)

    job = get_job(job_id)

    if job is None:
        raise HTTPException(
            status_code=404,
            detail="Job not found",
        )

    profile = get_profile(job["package"])

    return {
        **job,
        "profile": profile,
    }
