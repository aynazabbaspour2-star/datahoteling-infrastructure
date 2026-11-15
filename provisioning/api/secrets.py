import os
import secrets
from pathlib import Path


DEFAULT_SECRET_DIR = "/run/datahoteling-provisioning/secrets"

SECRET_DIR = Path(
    os.getenv(
        "DATAHOTELING_SECRET_DIR",
        DEFAULT_SECRET_DIR,
    )
)


def ensure_secret_dir():
    SECRET_DIR.mkdir(
        mode=0o700,
        parents=True,
        exist_ok=True,
    )

    os.chmod(SECRET_DIR, 0o700)


def _secret_path(job_id):
    if not job_id or "/" in job_id or "\\" in job_id:
        raise ValueError("Invalid job_id")

    return SECRET_DIR / f"{job_id}.secret"


def write_secret(job_id, secret):
    if not secret:
        raise ValueError("Secret cannot be empty")

    ensure_secret_dir()

    path = _secret_path(job_id)

    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL

    fd = os.open(
        path,
        flags,
        0o600,
    )

    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(secret)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
    except Exception:
        try:
            path.unlink()
        except FileNotFoundError:
            pass
        raise

    os.chmod(path, 0o600)

    return path


def read_secret(job_id):
    path = _secret_path(job_id)

    with path.open(
        "r",
        encoding="utf-8",
    ) as handle:
        secret = handle.readline().rstrip("\n")

    if not secret:
        raise RuntimeError(
            f"Secret file is empty for job {job_id}"
        )

    return secret


def delete_secret(job_id):
    path = _secret_path(job_id)

    try:
        path.unlink()
    except FileNotFoundError:
        pass


def secret_exists(job_id):
    return _secret_path(job_id).is_file()


def cleanup_orphan_secrets(valid_job_ids):
    ensure_secret_dir()

    valid = set(valid_job_ids)

    for path in SECRET_DIR.glob("*.secret"):
        job_id = path.stem

        if job_id not in valid:
            try:
                path.unlink()
            except FileNotFoundError:
                pass


def generate_secret_name():
    return secrets.token_hex(16)
