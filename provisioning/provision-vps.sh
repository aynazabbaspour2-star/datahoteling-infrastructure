#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRODUCTION_DIR="${ROOT_DIR}/terraform/environments/production"

BOOTSTRAP_SCRIPT="${ROOT_DIR}/provisioning/scripts/bootstrap-vps.sh"
HEALTH_SCRIPT="${ROOT_DIR}/provisioning/scripts/health-check.sh"

ADMIN_USER="${ADMIN_USER:-aynaz}"
CUSTOMER_USER="${CUSTOMER_USER:-customer1}"
CUSTOMER_HOSTNAME="${CUSTOMER_HOSTNAME:-dh-vps-wrapper-01}"
TERRAFORM_WORKSPACE="${TERRAFORM_WORKSPACE:-wrapper-test}"

SSH_OPTIONS=(
    -o ConnectTimeout=5
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -o PasswordAuthentication=no
)

echo
echo "========================================"
echo " DATAHOTELING VPS PROVISIONING WRAPPER"
echo "========================================"
echo
echo "Root directory : ${ROOT_DIR}"
echo "Terraform dir  : ${PRODUCTION_DIR}"
echo "Admin user     : ${ADMIN_USER}"
echo "Customer user  : ${CUSTOMER_USER}"
echo "Hostname       : ${CUSTOMER_HOSTNAME}"
echo "Terraform workspace: ${TERRAFORM_WORKSPACE}"
echo

if [ ! -f "${BOOTSTRAP_SCRIPT}" ]; then
    echo "ERROR: Bootstrap script not found:"
    echo "${BOOTSTRAP_SCRIPT}"
    exit 1
fi

if [ ! -f "${HEALTH_SCRIPT}" ]; then
    echo "ERROR: Health script not found:"
    echo "${HEALTH_SCRIPT}"
    exit 1
fi

echo "===== [1/6] TERRAFORM VALIDATION ====="

cd "${PRODUCTION_DIR}" || exit 1

echo "Selecting Terraform workspace: ${TERRAFORM_WORKSPACE}"

if terraform workspace list | sed 's/^* //' | grep -Fxq "${TERRAFORM_WORKSPACE}"; then
    terraform workspace select "${TERRAFORM_WORKSPACE}"
else
    echo "ERROR: Terraform workspace '${TERRAFORM_WORKSPACE}' does not exist"
    exit 1
fi

echo "Active workspace: $(terraform workspace show)"

terraform validate

if [ $? -ne 0 ]; then
    echo "ERROR: Terraform validation failed"
    exit 1
fi

echo
echo "TERRAFORM_VALIDATE_OK"

echo
echo "===== [2/6] TERRAFORM APPLY ====="

terraform apply -auto-approve

if [ $? -ne 0 ]; then
    echo "ERROR: Terraform apply failed"
    exit 1
fi

echo
echo "TERRAFORM_APPLY_OK"

echo
echo "===== [3/6] GET VPS IP ====="

VM_IP="$(terraform output -raw vm_ip 2>/dev/null)"

if [ -z "${VM_IP}" ] || [ "${VM_IP}" = "null" ]; then
    echo "ERROR: Terraform did not return a VM IP"
    exit 1
fi

echo "VPS IP: ${VM_IP}"

echo
echo "===== [4/6] WAIT FOR SSH ====="

SSH_READY=0

for attempt in $(seq 1 30); do
    echo "SSH attempt ${attempt}/30..."

    ssh "${SSH_OPTIONS[@]}" \
        "${ADMIN_USER}@${VM_IP}" \
        'echo SSH_READY' >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        SSH_READY=1
        break
    fi

    sleep 5
done

if [ "${SSH_READY}" -ne 1 ]; then
    echo
    echo "ERROR: SSH did not become ready"
    exit 1
fi

echo
echo "SSH_READY_OK"

echo
echo "===== [5/6] BOOTSTRAP VPS ====="

echo "Uploading bootstrap script..."

scp "${SSH_OPTIONS[@]}" \
    "${BOOTSTRAP_SCRIPT}" \
    "${ADMIN_USER}@${VM_IP}:/tmp/datahoteling-bootstrap-vps.sh"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to upload bootstrap script"
    exit 1
fi

echo
echo "Running bootstrap..."

ssh -t "${SSH_OPTIONS[@]}" \
    "${ADMIN_USER}@${VM_IP}" \
    "sudo CUSTOMER_USER='${CUSTOMER_USER}' CUSTOMER_HOSTNAME='${CUSTOMER_HOSTNAME}' bash /tmp/datahoteling-bootstrap-vps.sh"

if [ $? -ne 0 ]; then
    echo "ERROR: Bootstrap failed"
    exit 1
fi

echo
echo "BOOTSTRAP_STAGE_OK"

echo
echo "Cleaning bootstrap script from VPS..."

ssh "${SSH_OPTIONS[@]}" \
    "${ADMIN_USER}@${VM_IP}" \
    "sudo rm -f /tmp/datahoteling-bootstrap-vps.sh"

echo
echo "===== [6/6] HEALTH CHECK ====="

scp "${SSH_OPTIONS[@]}" \
    "${HEALTH_SCRIPT}" \
    "${ADMIN_USER}@${VM_IP}:/tmp/datahoteling-health-check.sh"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to upload health check"
    exit 1
fi

ssh "${SSH_OPTIONS[@]}" \
    "${ADMIN_USER}@${VM_IP}" \
    "sudo CUSTOMER_USER='${CUSTOMER_USER}' bash /tmp/datahoteling-health-check.sh"

HEALTH_RESULT=$?

ssh "${SSH_OPTIONS[@]}" \
    "${ADMIN_USER}@${VM_IP}" \
    "sudo rm -f /tmp/datahoteling-health-check.sh" \
    >/dev/null 2>&1

if [ "${HEALTH_RESULT}" -ne 0 ]; then
    echo
    echo "ERROR: Health check failed"
    exit 1
fi

echo
echo "========================================"
echo " VPS PROVISIONING COMPLETE"
echo "========================================"
echo
echo "Status       : READY"
echo "IP address   : ${VM_IP}"
echo "Username     : ${CUSTOMER_USER}"
echo "Hostname     : ${CUSTOMER_HOSTNAME}"
echo
echo "========================================"
