#!/usr/bin/env bash

set -uo pipefail

echo "========== DATAHOTELING SECURITY CHECK =========="

FAILED=0

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: This script must run inside a Git repository."
    exit 2
fi

echo
echo "[1/4] Scanning file names and repository paths..."

python3 - <<'PY'
from pathlib import Path
import subprocess
import re
import sys

result = subprocess.run(
    ["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
)

if result.returncode != 0:
    print("ERROR: Unable to enumerate Git files.")
    sys.exit(2)

paths = [
    item.decode("utf-8", errors="replace")
    for item in result.stdout.split(b"\0")
    if item
]

sensitive_patterns = [
    re.compile(r"(^|/)\.env($|\.(?!example$))", re.I),
    re.compile(r"\.tfvars(\.json)?$", re.I),
    re.compile(r"\.pkrvars\.hcl$", re.I),
    re.compile(r"\.tfstate($|\.)", re.I),
    re.compile(r"\.tfplan($|-)", re.I),
    re.compile(r"\.(pem|key)$", re.I),
    re.compile(r"\.(db|sqlite|sqlite3)$", re.I),
    re.compile(r"(^|/)(packer_ed25519|id_rsa|id_ed25519|id_ecdsa)$", re.I),
    re.compile(r"(^|/)(\.venv|\.venv-vsphere|_archive|backups?)(/|$)", re.I),
    re.compile(r"(^|/)[^/]*(backup|\.bak)([^/]*)$", re.I),
    re.compile(r"\.log$", re.I),
]

findings = []

for name in paths:
    if any(pattern.search(name) for pattern in sensitive_patterns):
        findings.append(name)

if findings:
    print("ERROR: Sensitive or excluded paths found:")
    for name in sorted(findings):
        print(f"  {name}")
    sys.exit(1)

print(f"OK: Checked {len(paths)} Git-visible file paths.")
print("OK: No sensitive filenames or excluded directories detected.")
PY

if [ $? -ne 0 ]; then
    FAILED=1
fi

echo
echo "[2/4] Scanning tracked and untracked text files for secrets..."

python3 - <<'PY'
from pathlib import Path
import subprocess
import re
import sys

result = subprocess.run(
    ["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
)

if result.returncode != 0:
    print("ERROR: Unable to enumerate files.")
    sys.exit(2)

paths = [
    item.decode("utf-8", errors="replace")
    for item in result.stdout.split(b"\0")
    if item
]

patterns = [
    ("Private key material",
     re.compile(rb"-----BEGIN (?:RSA |OPENSSH |EC |DSA |)PRIVATE KEY-----")),
    ("AWS access key",
     re.compile(rb"\bAKIA[0-9A-Z]{16}\b")),
    ("GitHub token",
     re.compile(rb"\b(?:gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,})\b")),
    ("Slack token",
     re.compile(rb"\bxox[baprs]-[A-Za-z0-9-]{10,}\b")),
    ("Stripe live secret",
     re.compile(rb"\b(?:sk|rk)_live_[A-Za-z0-9]{16,}\b")),
    ("Google API key",
     re.compile(rb"\bAIza[0-9A-Za-z_-]{30,}\b")),
    ("Credential URL",
     re.compile(rb"://[^/\s:@]+:[^/\s@]+@")),
]

assignment = re.compile(
    rb"""(?i)\b(password|passwd|secret|token|api[_-]?key|client_secret|access_key)\b\s*[:=]\s*["']([^"']{8,})["']"""
)

allowed_placeholders = {
    b"ci-validation-only",
    b"example",
}

findings = []

for name in paths:
    path = Path(name)

    if not path.is_file():
        continue

    try:
        data = path.read_bytes()
    except OSError:
        findings.append((name, 0, "Unreadable file"))
        continue

    # Binary files are handled by filename checks, not text scanning.
    if b"\0" in data:
        continue

    for line_number, line in enumerate(data.splitlines(), 1):
        for label, pattern in patterns:
            if pattern.search(line):
                findings.append((name, line_number, label))

        for match in assignment.finditer(line):
            value = match.group(2).strip()
            if value not in allowed_placeholders:
                findings.append((name, line_number, "Possible hard-coded credential"))

if findings:
    print("ERROR: Possible secret material detected.")
    print("Values are intentionally NOT displayed.")

    for name, line, label in sorted(set(findings)):
        print(f"  {name}:{line} — {label}")

    sys.exit(1)

print(f"OK: Scanned {len(paths)} Git-visible file paths.")
print("OK: No matching secret patterns detected.")
PY

if [ $? -ne 0 ]; then
    FAILED=1
fi

echo
echo "[3/4] Checking sensitive tracked filenames..."

python3 - <<'PY'
import subprocess
import re
import sys

result = subprocess.run(
    ["git", "ls-files", "-z"],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
)

if result.returncode != 0:
    print("ERROR: Unable to inspect tracked files.")
    sys.exit(2)

paths = [
    item.decode("utf-8", errors="replace")
    for item in result.stdout.split(b"\0")
    if item
]

pattern = re.compile(
    r"(^|/)(\.env($|\.(?!example$))|[^/]+\.tfvars(\.json)?$|"
    r"[^/]+\.pkrvars\.hcl$|packer_ed25519$|id_(rsa|ed25519|ecdsa)$|"
    r"[^/]+\.(pem|key|credentials|tfstate|tfplan|db|sqlite|sqlite3)$)",
    re.I,
)

findings = [name for name in paths if pattern.search(name)]

if findings:
    print("ERROR: Sensitive filenames are tracked:")
    for name in sorted(findings):
        print(f"  {name}")
    sys.exit(1)

print(f"OK: Checked {len(paths)} tracked files.")
print("OK: No sensitive filenames are tracked.")
PY

if [ $? -ne 0 ]; then
    FAILED=1
fi

echo
echo "[4/4] Final result..."

if [ "$FAILED" -ne 0 ]; then
    echo "SECURITY CHECK FAILED."
    exit 1
fi

echo "SECURITY CHECK PASSED."
