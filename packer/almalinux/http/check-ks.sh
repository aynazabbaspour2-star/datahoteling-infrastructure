#!/usr/bin/env bash

echo "=== Kickstart checks ==="

grep -q '^#version=RHEL9' ks.cfg || {
    echo "ERROR: RHEL9 version missing"
    exit 1
}

grep -q '^cdrom$' ks.cfg || {
    echo "ERROR: cdrom directive missing"
    exit 1
}

grep -q '^network ' ks.cfg || {
    echo "ERROR: network directive missing"
    exit 1
}

grep -q '^user --name=packer' ks.cfg || {
    echo "ERROR: packer user missing"
    exit 1
}

grep -q '^%packages$' ks.cfg || {
    echo "ERROR: %packages missing"
    exit 1
}

grep -q '^%post' ks.cfg || {
    echo "ERROR: %post missing"
    exit 1
}

grep -q 'dnf install -y cloud-init open-vm-tools wget' ks.cfg || {
    echo "ERROR: post-install package command missing"
    exit 1
}

grep -q '^reboot$' ks.cfg || {
    echo "ERROR: reboot directive missing"
    exit 1
}

if grep -q '^hostname ' ks.cfg; then
    echo "ERROR: hostname must not be hardcoded in Golden Image"
    exit 1
fi

if grep -qE 'cloud-init|open-vm-tools|wget' ks.cfg | grep -q '^'; then
    :
fi

echo
echo "OK: Kickstart structure looks correct."
echo
echo "Packages installed by installer:"
grep -A20 '^%packages$' ks.cfg | sed '/^%end$/q'

echo
echo "Post-install packages:"
grep 'dnf install' ks.cfg
