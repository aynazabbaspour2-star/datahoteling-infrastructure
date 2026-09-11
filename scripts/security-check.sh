#!/usr/bin/env bash

echo "========== DATAHOTELING SECURITY CHECK =========="

FAILED=0

echo
echo "[1/4] Checking for private keys..."

if git grep -n -I -E -- \
  '-----BEGIN (RSA|OPENSSH|EC|DSA|PRIVATE) KEY-----' \
  -- ':!*.md'; then
  echo "ERROR: Private key material detected."
  FAILED=1
else
  echo "OK: No private key material detected."
fi

echo
echo "[2/4] Checking for common cloud/API secrets..."

if git grep -n -I -E -- \
  '(AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,})' \
  -- ':!*.md'; then
  echo "ERROR: Possible API/token secret detected."
  FAILED=1
else
  echo "OK: No common API token patterns detected."
fi

echo
echo "[3/4] Checking for hard-coded credential assignments..."

if git grep -n -I -E -- \
  '(password|passwd|secret|token)[[:space:]]*=[[:space:]]*["'\''][^"'\'']{8,}["'\'']' \
  -- '*.tf' '*.tfvars' '*.hcl' '*.yaml' '*.yml' '*.json' '*.sh'; then
  echo "WARNING: Possible hard-coded credential assignment detected."
  FAILED=1
else
  echo "OK: No obvious hard-coded credential assignments detected."
fi

echo
echo "[4/4] Checking tracked sensitive filenames..."

SENSITIVE_FILES="$(git ls-files | grep -E \
  '(^|/)(\.env|.*\.tfvars$|.*\.tfvars\.json$|.*\.pkrvars\.hcl$|id_(rsa|ed25519|ecdsa)|.*\.pem$|.*\.key$|.*\.credentials$)' \
  || true)"

if [ -n "$SENSITIVE_FILES" ]; then
  echo "ERROR: Sensitive files are tracked:"
  echo "$SENSITIVE_FILES"
  FAILED=1
else
  echo "OK: No sensitive filenames are tracked."
fi

echo

if [ "$FAILED" -ne 0 ]; then
  echo "SECURITY CHECK FAILED."
  exit 1
fi

echo "SECURITY CHECK PASSED."
