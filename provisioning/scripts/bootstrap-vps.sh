#!/usr/bin/env bash

echo "===== DATAHOTELING VPS BOOTSTRAP ====="

CUSTOMER_USER="${CUSTOMER_USER:-customer1}"
CUSTOMER_HOSTNAME="${CUSTOMER_HOSTNAME:-dh-vps}"

echo "Customer user : ${CUSTOMER_USER}"
echo "Hostname      : ${CUSTOMER_HOSTNAME}"
echo

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: bootstrap-vps.sh must run as root"
    exit 1
fi

echo "[1/6] Setting hostname..."
hostnamectl set-hostname "${CUSTOMER_HOSTNAME}"

echo "[2/6] Creating customer user..."

if id "${CUSTOMER_USER}" >/dev/null 2>&1; then
    echo "User ${CUSTOMER_USER} already exists"
else
    useradd -m -s /bin/bash "${CUSTOMER_USER}"
fi

echo "[3/6] Setting customer password..."

if [ -t 0 ]; then
    read -r -s -p "Customer password: " CUSTOMER_PASSWORD
    echo
else
    IFS= read -r CUSTOMER_PASSWORD
fi

if [ -z "${CUSTOMER_PASSWORD}" ]; then
    echo "ERROR: Customer password cannot be empty"
    exit 1
fi

printf '%s:%s\n' "${CUSTOMER_USER}" "${CUSTOMER_PASSWORD}" | chpasswd

unset CUSTOMER_PASSWORD

echo "[4/6] Granting sudo access..."

usermod -aG sudo "${CUSTOMER_USER}"

echo "[5/6] Configuring SSH..."

SSHD_CONFIG="/etc/ssh/sshd_config"

sed -i 's/^[#[:space:]]*PasswordAuthentication.*/PasswordAuthentication yes/' "${SSHD_CONFIG}"

if ! grep -q '^PasswordAuthentication yes' "${SSHD_CONFIG}"; then
    echo 'PasswordAuthentication yes' >> "${SSHD_CONFIG}"
fi

if command -v systemctl >/dev/null 2>&1; then
    systemctl reload ssh 2>/dev/null || \
    systemctl reload sshd 2>/dev/null || true
fi

echo "[6/6] Verification..."

echo
echo "Hostname:"
hostname

echo
echo "Network:"
ip -br addr

echo
echo "Customer:"
id "${CUSTOMER_USER}"

echo
echo "Uptime:"
uptime

echo
echo "BOOTSTRAP_OK"
