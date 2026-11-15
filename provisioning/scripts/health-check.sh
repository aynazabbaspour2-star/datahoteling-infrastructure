#!/usr/bin/env bash

set -u

CUSTOMER_USER="${CUSTOMER_USER:-customer1}"

echo "===== DATAHOTELING VPS HEALTH CHECK ====="

echo "[1/5] Hostname:"
hostname

echo
echo "[2/5] Network:"
ip -br addr

echo
echo "[3/5] SSH service:"

if systemctl is-active --quiet ssh 2>/dev/null || \
   systemctl is-active --quiet sshd 2>/dev/null; then
    echo "SSH_OK"
else
    echo "ERROR: SSH service is not active"
    exit 1
fi

echo
echo "[4/5] Customer user:"

if id "${CUSTOMER_USER}" >/dev/null 2>&1; then
    id "${CUSTOMER_USER}"
else
    echo "ERROR: customer user does not exist"
    exit 1
fi

echo
echo "[5/5] Connectivity:"

if ip route get 8.8.8.8 >/dev/null 2>&1; then
    echo "NETWORK_ROUTE_OK"
else
    echo "WARNING: no route to 8.8.8.8"
fi

echo
echo "HEALTH_CHECK_OK"
