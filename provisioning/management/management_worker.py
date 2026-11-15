#!/home/aynaz/datahoteling-infrastructure/.venv-vsphere/bin/python3.12

import os
import ssl
import sys
import time
import subprocess
from datetime import datetime, timezone
from pathlib import Path

from pyVim import connect
from pyVmomi import vim


ROOT_DIR = Path("/home/aynaz/datahoteling-infrastructure")

if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))


from provisioning.api.db import (
    claim_next_management_operation,
    get_job,
    update_management_operation,
)
from provisioning.api.secrets import read_secret, delete_secret
from provisioning.api.profiles import get_profile


ENV_FILE = (
    ROOT_DIR
    / "deploy"
    / "env"
    / "datahoteling-provisioning-worker.env"
)


TASK_TIMEOUT = 300


def now_iso():
    return datetime.now(timezone.utc).isoformat()


def load_environment():
    if not ENV_FILE.exists():
        raise RuntimeError(
            f"Environment file not found: {ENV_FILE}"
        )

    for line in ENV_FILE.read_text().splitlines():
        line = line.strip()

        if (
            not line
            or line.startswith("#")
            or "=" not in line
        ):
            continue

        key, value = line.split("=", 1)

        value = (
            value
            .strip()
            .strip('"')
            .strip("'")
        )

        os.environ.setdefault(key, value)


def connect_vcenter():
    server = os.environ.get(
        "TF_VAR_vsphere_server"
    )

    user = os.environ.get(
        "TF_VAR_vsphere_user"
    )

    password = os.environ.get(
        "TF_VAR_vsphere_password"
    )

    if not server:
        raise RuntimeError(
            "Missing TF_VAR_vsphere_server"
        )

    if not user:
        raise RuntimeError(
            "Missing TF_VAR_vsphere_user"
        )

    if not password:
        raise RuntimeError(
            "Missing TF_VAR_vsphere_password"
        )

    context = ssl._create_unverified_context()

    return connect.SmartConnect(
        host=server,
        user=user,
        pwd=password,
        sslContext=context,
    )


def find_vm(content, service_id):
    target_name = f"DH-VPS-{service_id}"

    view = content.viewManager.CreateContainerView(
        content.rootFolder,
        [vim.VirtualMachine],
        True,
    )

    try:
        for vm in view.view:
            if vm.name == target_name:
                return vm
    finally:
        view.Destroy()

    raise RuntimeError(
        f"VM not found: {target_name}"
    )


def wait_for_task(task, timeout=TASK_TIMEOUT):
    started = time.monotonic()

    while True:
        state = task.info.state

        if state == vim.TaskInfo.State.success:
            return

        if state == vim.TaskInfo.State.error:
            error = task.info.error

            if error is not None:
                raise RuntimeError(
                    f"vCenter task failed: {error}"
                )

            raise RuntimeError(
                "vCenter task failed"
            )

        if (
            time.monotonic() - started
            > timeout
        ):
            raise TimeoutError(
                "vCenter task timed out"
            )

        time.sleep(1)


def wait_for_power_state(
    vm,
    expected_state,
    timeout=TASK_TIMEOUT,
):
    started = time.monotonic()

    while True:
        current_state = vm.runtime.powerState

        if current_state == expected_state:
            return

        if (
            time.monotonic() - started
            > timeout
        ):
            raise TimeoutError(
                "Timed out waiting for VM power state "
                f"{expected_state}; "
                f"current={current_state}"
            )

        time.sleep(1)


def power_on(vm):
    current = vm.runtime.powerState

    if (
        current
        == vim.VirtualMachinePowerState.poweredOn
    ):
        print(
            "VM already poweredOn; "
            "power_on is idempotent."
        )
        return

    if (
        current
        != vim.VirtualMachinePowerState.poweredOff
    ):
        raise RuntimeError(
            "Cannot power on VM from state: "
            + str(current)
        )

    print("Sending PowerOnVM_Task...")

    task = vm.PowerOnVM_Task()

    wait_for_task(task)

    wait_for_power_state(
        vm,
        vim.VirtualMachinePowerState.poweredOn,
    )

    print(
        "VM power state verified: poweredOn"
    )


def shutdown_vm(vm):
    current = vm.runtime.powerState

    if (
        current
        == vim.VirtualMachinePowerState.poweredOff
    ):
        print(
            "VM already poweredOff; "
            "shutdown is idempotent."
        )
        return

    if (
        current
        != vim.VirtualMachinePowerState.poweredOn
    ):
        raise RuntimeError(
            "Cannot shutdown VM from state: "
            + str(current)
        )

    print(
        "Sending PowerOffVM_Task..."
    )

    task = vm.PowerOffVM_Task()

    wait_for_task(task)

    wait_for_power_state(
        vm,
        vim.VirtualMachinePowerState.poweredOff,
    )

    print(
        "VM power state verified: poweredOff"
    )


def restart_vm(vm):
    current = vm.runtime.powerState

    if (
        current
        == vim.VirtualMachinePowerState.poweredOff
    ):
        print(
            "VM is poweredOff; "
            "restart will power it on."
        )

        task = vm.PowerOnVM_Task()

        wait_for_task(task)

        wait_for_power_state(
            vm,
            vim.VirtualMachinePowerState.poweredOn,
        )

        print(
            "VM power state verified: poweredOn"
        )

        return

    if (
        current
        != vim.VirtualMachinePowerState.poweredOn
    ):
        raise RuntimeError(
            "Cannot restart VM from state: "
            + str(current)
        )

    tools_status = vm.guest.toolsRunningStatus

    if tools_status != "guestToolsRunning":
        raise RuntimeError(
            "VMware Tools are not running; "
            "graceful restart is unavailable. "
            "toolsRunningStatus="
            + str(tools_status)
        )

    print(
        "Sending graceful guest reboot request..."
    )

    vm.RebootGuest()

    wait_for_power_state(
        vm,
        vim.VirtualMachinePowerState.poweredOn,
    )

    print(
        "Graceful guest reboot request accepted."
    )

    print(
        "VM restart completed; "
        "power state verified: poweredOn"
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


def change_password(operation):
    operation_id = operation["operation_id"]
    service_id = int(operation["service_id"])

    job = get_job_for_service(service_id)

    if job is None:
        raise RuntimeError(
            f"No provisioning job found for service {service_id}"
        )

    vm_ip = job.get("vm_ip")
    customer_username = job.get("customer_username")

    if not vm_ip:
        raise RuntimeError(
            f"No VM IP available for service {service_id}"
        )

    if not customer_username:
        raise RuntimeError(
            f"No customer username available for service {service_id}"
        )

    password = read_secret(operation_id)

    try:
        command = ssh_base_command(vm_ip) + [
            "sudo",
            "-n",
            "chpasswd",
        ]

        result = subprocess.run(
            command,
            input=f"{customer_username}:{password}\n",
            text=True,
            capture_output=True,
            timeout=30,
            check=False,
        )

        if result.returncode != 0:
            raise RuntimeError(
                "Remote password change failed"
            )

        print(
            f"Password change completed for "
            f"Service ID {service_id}"
        )

    finally:
        delete_secret(operation_id)



def wait_for_guest_ip(vm, timeout=600):
    started = time.monotonic()

    while True:
        try:
            ip = vm.guest.ipAddress
        except Exception:
            ip = None

        if ip:
            print(f"Guest IP detected: {ip}")
            return ip

        if time.monotonic() - started > timeout:
            raise TimeoutError(
                "Timed out waiting for guest IP"
            )

        time.sleep(5)


def wait_for_ssh(vm_ip, timeout=300):
    started = time.monotonic()

    while True:
        command = ssh_base_command(vm_ip) + [
            "true",
        ]

        result = subprocess.run(
            command,
            input="",
            text=True,
            capture_output=True,
            timeout=20,
            check=False,
        )

        if result.returncode == 0:
            print("SSH connectivity verified.")
            return

        if time.monotonic() - started > timeout:
            raise TimeoutError(
                f"Timed out waiting for SSH on {vm_ip}"
            )

        time.sleep(5)


def scp_to_vm(vm_ip, local_path, remote_path):
    command = [
        "scp",
        "-o",
        "StrictHostKeyChecking=no",
        "-o",
        "UserKnownHostsFile=/dev/null",
        "-o",
        "ConnectTimeout=10",
        "-i",
        os.path.expanduser(
            "~/.ssh/datahoteling_provisioner"
        ),
        local_path,
        f"dhprovision@{vm_ip}:{remote_path}",
    ]

    result = subprocess.run(
        command,
        text=True,
        capture_output=True,
        timeout=60,
        check=False,
    )

    if result.returncode != 0:
        raise RuntimeError(
            "SCP to VPS failed"
        )


def run_reinstall_bootstrap(
    operation_id,
    vm_ip,
    customer_username,
    customer_hostname,
):
    password = read_secret(operation_id)

    bootstrap_path = (
        ROOT_DIR
        / "provisioning"
        / "scripts"
        / "bootstrap-vps.sh"
    )

    remote_path = "/tmp/datahoteling-bootstrap.sh"

    try:
        scp_to_vm(
            vm_ip,
            str(bootstrap_path),
            remote_path,
        )

        command = ssh_base_command(vm_ip) + [
            "sudo",
            "-n",
            "env",
            f"CUSTOMER_USER={customer_username}",
            f"CUSTOMER_HOSTNAME={customer_hostname}",
            "bash",
            remote_path,
        ]

        result = subprocess.run(
            command,
            input=f"{password}\n",
            text=True,
            capture_output=True,
            timeout=180,
            check=False,
        )

        if result.returncode != 0:
            raise RuntimeError(
                "Reinstall bootstrap failed"
            )

        if "BOOTSTRAP_OK" not in result.stdout:
            raise RuntimeError(
                "Reinstall bootstrap did not report BOOTSTRAP_OK"
            )

        print("Reinstall bootstrap completed.")

    finally:
        delete_secret(operation_id)

        cleanup = ssh_base_command(vm_ip) + [
            "sudo",
            "-n",
            "rm",
            "-f",
            remote_path,
        ]

        subprocess.run(
            cleanup,
            text=True,
            capture_output=True,
            timeout=30,
            check=False,
        )


def run_reinstall_health_check(
    vm_ip,
    customer_username,
):
    health_path = (
        ROOT_DIR
        / "provisioning"
        / "scripts"
        / "health-check.sh"
    )

    remote_path = "/tmp/datahoteling-health-check.sh"

    try:
        scp_to_vm(
            vm_ip,
            str(health_path),
            remote_path,
        )

        command = ssh_base_command(vm_ip) + [
            "sudo",
            "-n",
            "env",
            f"CUSTOMER_USER={customer_username}",
            "bash",
            remote_path,
        ]

        result = subprocess.run(
            command,
            text=True,
            capture_output=True,
            timeout=120,
            check=False,
        )

        if result.returncode != 0:
            raise RuntimeError(
                "Reinstall health check failed"
            )

        if "HEALTH_CHECK_OK" not in result.stdout:
            raise RuntimeError(
                "Reinstall health check did not report HEALTH_CHECK_OK"
            )

        print("Reinstall health check completed.")

    finally:
        cleanup = ssh_base_command(vm_ip) + [
            "sudo",
            "-n",
            "rm",
            "-f",
            remote_path,
        ]

        subprocess.run(
            cleanup,
            text=True,
            capture_output=True,
            timeout=30,
            check=False,
        )


def update_service_vm_ip(service_id, vm_ip):
    from provisioning.api.db import get_connection

    conn = get_connection()

    try:
        conn.execute(
            """
            UPDATE jobs
            SET vm_ip = ?,
                status = ?,
                error = NULL,
                updated_at = ?
            WHERE service_id = ?
            """,
            (
                vm_ip,
                "ready",
                now_iso(),
                service_id,
            ),
        )

        conn.commit()

    finally:
        conn.close()


def reinstall_vps(operation):
    operation_id = operation["operation_id"]
    service_id = int(operation["service_id"])

    job = get_job_for_service(service_id)

    if job is None:
        raise RuntimeError(
            f"No provisioning job found for service {service_id}"
        )

    customer_username = job.get("customer_username")
    customer_hostname = job.get("hostname")
    package = job.get("package")

    if not customer_username:
        raise RuntimeError(
            f"No customer username for service {service_id}"
        )

    if not customer_hostname:
        raise RuntimeError(
            f"No hostname for service {service_id}"
        )

    if not package:
        raise RuntimeError(
            f"No package for service {service_id}"
        )

    profile = get_profile(package)

    si = connect_vcenter()
    temp_vm = None
    old_vm = None
    handoff_started = False

    temp_name = (
        f"DH-VPS-{service_id}-reinstall-"
        f"{operation_id[:8]}"
    )

    try:
        content = si.RetrieveContent()

        old_vm = find_vm(
            content,
            service_id,
        )

        golden_name = "datahoteling-ubuntu-golden-test1"

        view = content.viewManager.CreateContainerView(
            content.rootFolder,
            [vim.VirtualMachine],
            True,
        )

        try:
            golden_vm = None

            for candidate in view.view:
                if candidate.name == golden_name:
                    golden_vm = candidate
                    break

        finally:
            view.Destroy()

        if golden_vm is None:
            raise RuntimeError(
                f"Golden image not found: {golden_name}"
            )

        if (
            golden_vm.runtime.powerState
            != vim.VirtualMachinePowerState.poweredOff
        ):
            raise RuntimeError(
                "Golden image must be poweredOff"
            )

        print(
            f"Creating reinstall clone: {temp_name}"
        )

        relocate = vim.vm.RelocateSpec()

        if old_vm.datastore:
            relocate.datastore = old_vm.datastore[0]

        if old_vm.runtime.host:
            relocate.host = old_vm.runtime.host

        if old_vm.resourcePool:
            relocate.pool = old_vm.resourcePool

        config = vim.vm.ConfigSpec()
        config.numCPUs = int(profile["num_cpus"])
        config.memoryMB = int(profile["memory_mb"])

        clone_spec = vim.vm.CloneSpec()
        clone_spec.location = relocate
        clone_spec.powerOn = False
        clone_spec.template = False
        clone_spec.config = config

        task = golden_vm.CloneVM_Task(
            folder=old_vm.parent,
            name=temp_name,
            spec=clone_spec,
        )

        wait_for_task(task)

        temp_vm = find_vm_by_name(
            content,
            temp_name,
        )

        print(
            f"Reinstall clone created: {temp_vm.name}"
        )

        print(
            f"CPU={temp_vm.config.hardware.numCPU} "
            f"RAM_MB={temp_vm.config.hardware.memoryMB}"
        )

        power_on(temp_vm)

        vm_ip = wait_for_guest_ip(temp_vm)

        wait_for_ssh(vm_ip)

        run_reinstall_bootstrap(
            operation_id,
            vm_ip,
            customer_username,
            customer_hostname,
        )

        run_reinstall_health_check(
            vm_ip,
            customer_username,
        )

        print(
            "New VPS passed bootstrap and health check."
        )

        shutdown_vm(temp_vm)

        print(
            f"Stopping old VM: {old_vm.name}"
        )

        shutdown_vm(old_vm)

        print(
            f"Deleting old VM: {old_vm.name}"
        )

        delete_task = old_vm.Destroy_Task()

        wait_for_task(delete_task)

        old_vm = None

        handoff_started = True

        print(
            f"Renaming reinstall VM to DH-VPS-{service_id}"
        )

        rename_task = temp_vm.Rename_Task(
            f"DH-VPS-{service_id}"
        )

        wait_for_task(rename_task)

        power_on(temp_vm)

        final_ip = wait_for_guest_ip(temp_vm)

        update_service_vm_ip(
            service_id,
            final_ip,
        )

        print(
            f"Reinstall completed for Service ID "
            f"{service_id}; IP={final_ip}"
        )

        temp_vm = None

    except Exception:
        if temp_vm is not None and not handoff_started:
            try:
                if (
                    temp_vm.runtime.powerState
                    == vim.VirtualMachinePowerState.poweredOn
                ):
                    shutdown_vm(temp_vm)
            except Exception:
                pass

            try:
                cleanup_task = temp_vm.Destroy_Task()
                wait_for_task(cleanup_task)
            except Exception:
                pass

        raise

    finally:
        connect.Disconnect(si)


def find_vm_by_name(content, name):
    view = content.viewManager.CreateContainerView(
        content.rootFolder,
        [vim.VirtualMachine],
        True,
    )

    try:
        for vm in view.view:
            if vm.name == name:
                return vm
    finally:
        view.Destroy()

    raise RuntimeError(
        f"VM not found: {name}"
    )

def get_job_for_service(service_id):
    from provisioning.api.db import get_connection

    conn = get_connection()

    try:
        row = conn.execute(
            "SELECT * FROM jobs WHERE service_id = ?",
            (service_id,),
        ).fetchone()

        if row is None:
            return None

        return dict(row)

    finally:
        conn.close()


def execute_operation(operation):
    service_id = int(
        operation["service_id"]
    )

    operation_name = (
        operation["operation"]
    )

    if operation_name == "change_password":
        change_password(operation)
        return

    if operation_name == "reinstall":
        reinstall_vps(operation)
        return

    si = connect_vcenter()

    try:
        content = si.RetrieveContent()

        vm = find_vm(
            content,
            service_id,
        )

        print(
            f"[{now_iso()}] "
            f"VM={vm.name} "
            f"Power={vm.runtime.powerState} "
            f"Operation={operation_name}"
        )

        if operation_name == "power_on":
            power_on(vm)
            return

        if operation_name == "power_shutdown":
            shutdown_vm(vm)
            return

        if operation_name == "power_restart":
            restart_vm(vm)
            return

        raise RuntimeError(
            "Unsupported management operation: "
            + operation_name
        )

    finally:
        connect.Disconnect(si)


def process_operation(operation):
    operation_id = (
        operation["operation_id"]
    )

    print()
    print("========================================")
    print(" MANAGEMENT OPERATION")
    print("========================================")
    print(
        "Operation ID:",
        operation_id,
    )
    print(
        "Service ID:",
        operation["service_id"],
    )
    print(
        "Operation:",
        operation["operation"],
    )
    print()

    try:
        execute_operation(
            operation
        )

        update_management_operation(
            operation_id,
            status="succeeded",
            error=None,
            finished_at=now_iso(),
            updated_at=now_iso(),
        )

        print()
        print(
            "RESULT: "
            "MANAGEMENT OPERATION SUCCEEDED"
        )

    except Exception as exc:
        message = str(exc)

        update_management_operation(
            operation_id,
            status="failed",
            error=message,
            finished_at=now_iso(),
            updated_at=now_iso(),
        )

        print()
        print(
            "RESULT: "
            "MANAGEMENT OPERATION FAILED"
        )
        print(
            "ERROR:",
            message,
        )


def run_once():
    load_environment()

    print(
        "========================================"
    )
    print(
        " DATAHOTELING MANAGEMENT WORKER"
    )
    print(
        "========================================"
    )
    print()

    operation = (
        claim_next_management_operation()
    )

    if operation is None:
        print(
            "No queued management operation."
        )
        return False

    process_operation(operation)

    return True


def main():
    load_environment()

    poll_interval = 5

    print("=" * 40)
    print(" DATAHOTELING MANAGEMENT WORKER")
    print("=" * 40)
    print()
    print("Mode: QUEUE WORKER")
    print(f"Poll interval: {poll_interval}s")
    print()

    while True:
        try:
            operation = claim_next_management_operation()

            if operation:
                process_operation(operation)
            else:
                time.sleep(poll_interval)

        except KeyboardInterrupt:
            print()
            print("Management worker stopped.")
            break

        except Exception as exc:
            print()
            print(f"QUEUE LOOP ERROR: {exc}")
            print("Retrying...")
            time.sleep(poll_interval)


if __name__ == "__main__":
    main()
