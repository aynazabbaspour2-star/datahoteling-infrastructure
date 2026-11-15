import os
import subprocess
import sys
import shlex
import signal
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[2]

if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from provisioning.api.db import claim_next_job, update_job
from provisioning.api.profiles import get_profile
from provisioning.api.secrets import read_secret, delete_secret

TERRAFORM_DIR = ROOT_DIR / "terraform" / "environments" / "production"
SCRIPTS_DIR = ROOT_DIR / "provisioning" / "scripts"


SHUTDOWN_REQUESTED = False


def request_shutdown(signum, frame):
    global SHUTDOWN_REQUESTED
    SHUTDOWN_REQUESTED = True
    print()
    print(f"===== WORKER SHUTDOWN REQUESTED (signal={signum}) =====")
    print("Current job will be allowed to finish.")


GOLDEN_IMAGES = {
    "ubuntu-24.04": {
        "template_uuid": "4231f1f9-eaec-e08f-a0af-eec93ce7bee8",
    },
}


def resolve_vps_configuration(job):
    config_fields = (
        job.get("os_type"),
        job.get("num_cpus"),
        job.get("memory_mb"),
        job.get("disk_size_gb"),
    )

    provided = [value is not None for value in config_fields]

    if not any(provided):
        profile = get_profile(job["package"])

        if profile is None:
            raise RuntimeError(
                f"Unknown package: {job['package']}"
            )

        return {
            "os_type": "ubuntu-24.04",
            "num_cpus": profile["num_cpus"],
            "memory_mb": profile["memory_mb"],
            "disk_size_gb": profile["disk_size_gb"],
            "template_uuid": GOLDEN_IMAGES["ubuntu-24.04"]["template_uuid"],
        }

    if not all(provided):
        raise RuntimeError(
            "Incomplete custom VPS configuration"
        )

    os_type = job["os_type"]
    image = GOLDEN_IMAGES.get(os_type)

    if image is None:
        raise RuntimeError(
            f"Unsupported OS type: {os_type}"
        )

    return {
        "os_type": os_type,
        "num_cpus": job["num_cpus"],
        "memory_mb": job["memory_mb"],
        "disk_size_gb": job["disk_size_gb"],
        "template_uuid": image["template_uuid"],
    }


def now_iso():
    return datetime.now(timezone.utc).isoformat()


def validate_vsphere_credentials():
    required = [
        "TF_VAR_vsphere_server",
        "TF_VAR_vsphere_user",
        "TF_VAR_vsphere_password",
    ]

    missing = [
        name
        for name in required
        if not os.environ.get(name)
    ]

    if missing:
        raise RuntimeError(
            "Missing required Terraform credential environment variables: "
            + ", ".join(missing)
        )

    print("===== TERRAFORM CREDENTIAL CHECK =====")
    print("TF_VAR_vsphere_server = SET")
    print("TF_VAR_vsphere_user   = SET")
    print("TF_VAR_vsphere_password = SET")
    print("Credential values are not printed.")


def run_command(command, cwd=None, input_text=None, timeout=None):
    print()
    print("COMMAND:")
    print(" ".join(command))
    print()

    try:
        result = subprocess.run(
            command,
            cwd=cwd,
            text=True,
            input=input_text,
            capture_output=True,
            env=os.environ.copy(),
            timeout=timeout,
        )
    except KeyboardInterrupt:
        print()
        print("COMMAND INTERRUPTED")
        raise

    except subprocess.TimeoutExpired:
        raise RuntimeError(
            "Command timed out: " + " ".join(command)
        )

    print("RETURN CODE:", result.returncode)

    if result.stdout:
        print("STDOUT:")
        print(result.stdout)

    if result.stderr:
        print("STDERR:")
        print(result.stderr)

    return result


def fail_job(job_id, message):
    print()
    print("===== JOB FAILED =====")
    print(message)

    update_job(
        job_id,
        status="failed",
        error=message,
        updated_at=now_iso(),
    )


def build_terraform_apply_command(job, configuration):
    service_id = job["service_id"]
    vm_name = f"DH-VPS-{service_id}"

    return [
        "terraform",
        "apply",
        "-input=false",
        "-auto-approve",
        f"-var=vm_name={vm_name}",
        f"-var=num_cpus={configuration['num_cpus']}",
        f"-var=memory_mb={configuration['memory_mb']}",
        f"-var=disk_size_gb={configuration['disk_size_gb']}",
        f"-var=template_uuid={configuration['template_uuid']}",
        "-no-color",
    ]


def get_terraform_vm_ip():
    result = run_command(
        [
            "terraform",
            "output",
            "-raw",
            "vm_ip",
        ],
        cwd=TERRAFORM_DIR,
    )

    if result.returncode != 0:
        raise RuntimeError(
            "Unable to read Terraform output vm_ip"
        )

    vm_ip = result.stdout.strip()

    if not vm_ip:
        raise RuntimeError(
            "Terraform returned an empty vm_ip"
        )

    return vm_ip


def ensure_workspace(workspace):
    print()
    print("===== TERRAFORM WORKSPACE =====")
    print(workspace)

    result = run_command(
        [
            "terraform",
            "workspace",
            "select",
            "-or-create",
            workspace,
        ],
        cwd=TERRAFORM_DIR,
    )

    if result.returncode != 0:
        raise RuntimeError(
            f"Unable to select/create Terraform workspace: {workspace}"
        )


def ssh_base_command(vm_ip):
    return [
        "ssh",
        "-o",
        "StrictHostKeyChecking=no",
        "-o",
        "UserKnownHostsFile=/dev/null",
        "-o",
        "ConnectTimeout=10",
        "-i",
        os.path.expanduser("~/.ssh/datahoteling_provisioner"),
        f"dhprovision@{vm_ip}",
    ]


def scp_to_vm(vm_ip, local_file, remote_file):
    command = [
        "scp",
        "-o",
        "StrictHostKeyChecking=no",
        "-o",
        "UserKnownHostsFile=/dev/null",
        "-o",
        "ConnectTimeout=10",
        "-i",
        os.path.expanduser("~/.ssh/datahoteling_provisioner"),
        str(local_file),
        f"dhprovision@{vm_ip}:{remote_file}",
    ]

    result = run_command(command, timeout=60)

    if result.returncode != 0:
        raise RuntimeError(
            f"Unable to upload {local_file.name} to {vm_ip}"
        )


def run_bootstrap(job, vm_ip):
    print()
    print("===== VPS BOOTSTRAP =====")

    bootstrap_script = SCRIPTS_DIR / "bootstrap-vps.sh"

    if not bootstrap_script.exists():
        raise RuntimeError(
            f"Bootstrap script not found: {bootstrap_script}"
        )

    job_id = job["job_id"]

    try:
        password = read_secret(job_id)
    except Exception as exc:
        raise RuntimeError(
            f"Unable to read customer password secret for job {job_id}: {exc}"
        ) from exc

    customer_user = job["customer_username"]
    hostname = job["hostname"]

    remote_script = "/tmp/datahoteling-bootstrap.sh"

    scp_to_vm(
        vm_ip,
        bootstrap_script,
        remote_script,
    )

    remote_command = (
        "sudo "
        f"env CUSTOMER_USER={shlex.quote(customer_user)} "
        f"CUSTOMER_HOSTNAME={shlex.quote(hostname)} "
        f"bash {remote_script}"
    )

    try:
        result = run_command(
            ssh_base_command(vm_ip) + [remote_command],
            input_text=password + "\n",
            timeout=120,
        )

        if result.returncode != 0:
            raise RuntimeError(
                f"Bootstrap failed for VM {vm_ip}"
            )

    finally:
        password = None

        try:
            delete_secret(job_id)
            print(f"Customer password secret deleted for job {job_id}")
        except Exception as exc:
            print(
                f"WARNING: unable to delete customer password secret "
                f"for job {job_id}: {exc}"
            )

    cleanup_command = (
        f"sudo rm -f {remote_script}"
    )

    cleanup = run_command(
        ssh_base_command(vm_ip) + [cleanup_command],
        timeout=30,
    )

    if cleanup.returncode != 0:
        print("WARNING: bootstrap temporary file cleanup failed")

    if "BOOTSTRAP_OK" not in result.stdout:
        raise RuntimeError(
            "Bootstrap completed without BOOTSTRAP_OK"
        )

    print("BOOTSTRAP_OK")


def run_health_check(job, vm_ip):
    print()
    print("===== VPS HEALTH CHECK =====")

    health_script = SCRIPTS_DIR / "health-check.sh"

    if not health_script.exists():
        raise RuntimeError(
            f"Health check script not found: {health_script}"
        )

    customer_user = job["customer_username"]

    remote_script = "/tmp/datahoteling-health-check.sh"

    scp_to_vm(
        vm_ip,
        health_script,
        remote_script,
    )

    remote_command = (
        "sudo "
        f"env CUSTOMER_USER={shlex.quote(customer_user)} "
        f"bash {remote_script}"
    )

    result = run_command(
        ssh_base_command(vm_ip) + [remote_command],
        timeout=60,
    )

    cleanup_command = (
        f"sudo rm -f {remote_script}"
    )

    cleanup = run_command(
        ssh_base_command(vm_ip) + [cleanup_command],
        timeout=30,
    )

    if cleanup.returncode != 0:
        print("WARNING: health check temporary file cleanup failed")

    if result.returncode != 0:
        raise RuntimeError(
            f"Health check failed for VM {vm_ip}"
        )

    if "HEALTH_CHECK_OK" not in result.stdout:
        raise RuntimeError(
            "Health check completed without HEALTH_CHECK_OK"
        )

    print("HEALTH_CHECK_OK")


def process_job(job):
    job_id = job["job_id"]

    print()
    print("========================================")
    print(" DATAHOTELING PROVISIONING WORKER")
    print("========================================")
    print()
    print("Job ID:", job_id)
    print("SERVICE ID:", job["service_id"])
    print("PACKAGE:", job["package"])
    print("HOSTNAME:", job["hostname"])
    print("CUSTOMER:", job["customer_username"])
    print("STATUS:", job["status"])

    try:
        validate_vsphere_credentials()

        configuration = resolve_vps_configuration(job)

        workspace = f"svc-{job['service_id']}"

        print()
        print("===== RESOLVED VPS CONFIGURATION =====")
        print("OS:", configuration["os_type"])
        print("CPU:", configuration["num_cpus"])
        print("RAM:", configuration["memory_mb"], "MB")
        print("DISK:", configuration["disk_size_gb"], "GB")
        print("GOLDEN IMAGE: configured")

        print()
        print("===== TERRAFORM DIRECTORY =====")
        print(TERRAFORM_DIR)

        update_job(
            job_id,
            status="provisioning",
            error=None,
            updated_at=now_iso(),
        )

        ensure_workspace(workspace)

        command = build_terraform_apply_command(
            job,
            configuration,
        )

        print()
        print("===== TERRAFORM APPLY =====")

        result = run_command(
            command,
            cwd=TERRAFORM_DIR,
            timeout=900,
        )

        if result.returncode != 0:
            raise RuntimeError(
                f"Terraform apply failed "
                f"(return code {result.returncode})"
            )

        print()
        print("===== TERRAFORM APPLY OK =====")

        print()
        print("===== READ VM IP =====")

        vm_ip = get_terraform_vm_ip()

        print("VM IP:", vm_ip)

        update_job(
            job_id,
            status="provisioning",
            vm_ip=vm_ip,
            error=None,
            updated_at=now_iso(),
        )

        run_bootstrap(
            job,
            vm_ip,
        )

        run_health_check(
            job,
            vm_ip,
        )

        update_job(
            job_id,
            status="ready",
            vm_ip=vm_ip,
            error=None,
            updated_at=now_iso(),
        )

        print()
        print("===== JOB READY =====")
        print("status = ready")
        print("vm_ip  =", vm_ip)
        print()
        print("WORKER_PROVISIONING_OK")

        return True

    except KeyboardInterrupt:
        if SHUTDOWN_REQUESTED:
            print()
            print("===== WORKER SHUTDOWN DURING JOB =====")
            print("Current job was interrupted before completion.")
            raise

        message = "Worker interrupted during job"
        fail_job(job_id, message)
        raise

    except Exception as exc:
        message = str(exc)
        fail_job(job_id, message)
        print()
        print("===== JOB FAILED =====")
        print("job_id =", job_id)
        print("error  =", message)
        return False


def main():
    signal.signal(signal.SIGINT, request_shutdown)
    signal.signal(signal.SIGTERM, request_shutdown)

    poll_interval = int(
        os.getenv("DATAHOTELING_WORKER_POLL_INTERVAL", "5")
    )

    print("========================================")
    print(" DATAHOTELING QUEUE WORKER")
    print("========================================")
    print()
    print("Poll interval:", poll_interval, "seconds")
    print("Terraform dir:", TERRAFORM_DIR)
    print()

    while True:
        try:
            if SHUTDOWN_REQUESTED:
                print()
                print("===== WORKER STOPPED =====")
                print("No new jobs will be claimed.")
                return

            job = claim_next_job()

            if job is None:
                print(
                    f"[{now_iso()}] Queue empty; "
                    f"sleeping {poll_interval}s..."
                )
                time.sleep(poll_interval)
                continue

            print()
            print(
                f"[{now_iso()}] Claimed job "
                f"{job['job_id']} "
                f"(service_id={job['service_id']})"
            )

            process_job(job)

            if SHUTDOWN_REQUESTED:
                print()
                print("===== WORKER STOPPED AFTER CURRENT JOB =====")
                return

            print()
            print("===== READY FOR NEXT JOB =====")
            print()

        except KeyboardInterrupt:
            print()
            print("Worker stopped by user.")
            print("QUEUE_WORKER_STOPPED")
            return

        except Exception as exc:
            print()
            print("===== WORKER LOOP ERROR =====")
            print(str(exc))
            print()
            print(
                f"Sleeping {poll_interval}s before retry..."
            )
            time.sleep(poll_interval)


if __name__ == "__main__":
    main()
