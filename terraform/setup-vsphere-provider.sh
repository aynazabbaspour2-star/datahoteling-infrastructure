#!/usr/bin/env bash

set -euo pipefail

RELEASE="2.16.1"
PROVIDER="vsphere"
NAMESPACE="vmware"
HOSTNAME="registry.terraform.io"

ZIP_NAME="terraform-provider-${PROVIDER}_${RELEASE}_linux_amd64.zip"

DOWNLOAD_URL="https://github.com/vmware/terraform-provider-vsphere/releases/download/v${RELEASE}/${ZIP_NAME}"

EXPECTED_SHA256="ac34720c18aff1031563951cdbe215c4420119895e90c3d94545a97e526b8d5f"

PLUGIN_ROOT="$HOME/.terraform.d/plugins"
MIRROR_DIR="$PLUGIN_ROOT/$HOSTNAME/$NAMESPACE/$PROVIDER/$RELEASE/linux_amd64"

TMP_DIR="/tmp/terraform-vsphere-${RELEASE}"

echo "=========================================="
echo " DataHoteling - Terraform vSphere Provider"
echo "=========================================="
echo

echo "[1/7] Creating temporary directory..."
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

echo "[2/7] Downloading vSphere provider ${RELEASE}..."
cd "$TMP_DIR"

curl -fL \
  --retry 3 \
  --retry-delay 2 \
  -o "$ZIP_NAME" \
  "$DOWNLOAD_URL"

echo
echo "[3/7] Verifying SHA256..."

ACTUAL_SHA256="$(sha256sum "$ZIP_NAME" | awk '{print $1}')"

echo "Expected:"
echo "$EXPECTED_SHA256"

echo
echo "Actual:"
echo "$ACTUAL_SHA256"
echo

if [[ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]]; then
    echo "ERROR: SHA256 verification failed!"
    exit 1
fi

echo "SHA256 verification: OK"

echo
echo "[4/7] Extracting provider..."

rm -rf "extracted"
mkdir -p "extracted"

unzip -oq "$ZIP_NAME" -d extracted

PROVIDER_BINARY="terraform-provider-${PROVIDER}_v${RELEASE}"

if [[ ! -f "extracted/$PROVIDER_BINARY" ]]; then
    echo "ERROR: Provider binary not found:"
    echo "extracted/$PROVIDER_BINARY"
    exit 1
fi

echo "Provider binary found."

echo
echo "[5/7] Creating Terraform filesystem mirror..."

mkdir -p "$MIRROR_DIR"

cp \
  "extracted/$PROVIDER_BINARY" \
  "$MIRROR_DIR/$PROVIDER_BINARY"

chmod +x "$MIRROR_DIR/$PROVIDER_BINARY"

echo "Provider installed at:"
echo "$MIRROR_DIR/$PROVIDER_BINARY"

echo
echo "[6/7] Creating Terraform CLI configuration..."

cat > "$HOME/.terraformrc" <<EOF
provider_installation {
  filesystem_mirror {
    path    = "$PLUGIN_ROOT"
    include = ["${HOSTNAME}/${NAMESPACE}/${PROVIDER}"]
  }

  direct {
    exclude = ["${HOSTNAME}/${NAMESPACE}/${PROVIDER}"]
  }
}
EOF

echo "Terraform CLI configuration:"
echo
cat "$HOME/.terraformrc"

echo
echo "[7/7] Verifying installation..."

echo
echo "Installed provider:"
ls -lh "$MIRROR_DIR"

echo
echo "=========================================="
echo " DONE"
echo "=========================================="
echo
echo "Provider:"
echo "${HOSTNAME}/${NAMESPACE}/${PROVIDER} ${RELEASE}"
echo
echo "Mirror:"
echo "$MIRROR_DIR"
echo
echo "Next step:"
echo "terraform init"
echo
