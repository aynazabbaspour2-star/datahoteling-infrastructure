import sqlite3
from datetime import datetime, timezone
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent / "provisioning.db"


def get_connection():
    conn = sqlite3.connect(
        DB_PATH,
        timeout=5.0,
    )

    conn.row_factory = sqlite3.Row

    # SQLite hardening for concurrent API + worker access.
    conn.execute("PRAGMA busy_timeout = 5000")
    conn.execute("PRAGMA foreign_keys = ON")
    conn.execute("PRAGMA journal_mode = WAL")
    conn.execute("PRAGMA synchronous = NORMAL")

    return conn


def init_db():
    conn = get_connection()

    conn.execute("""
        CREATE TABLE IF NOT EXISTS jobs (
            job_id TEXT PRIMARY KEY,
            service_id INTEGER NOT NULL,
            package TEXT NOT NULL,
            hostname TEXT NOT NULL,
            customer_username TEXT NOT NULL,
            status TEXT NOT NULL,
            vm_ip TEXT,
            error TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
        )
    """)

    # Backward-compatible VPS configurator fields.
    # Existing jobs keep these values as NULL and continue
    # using their package profile.
    columns = {
        row["name"]
        for row in conn.execute("PRAGMA table_info(jobs)").fetchall()
    }

    for column, column_type in (
        ("os_type", "TEXT"),
        ("num_cpus", "INTEGER"),
        ("memory_mb", "INTEGER"),
        ("disk_size_gb", "INTEGER"),
    ):
        if column not in columns:
            conn.execute(
                f"ALTER TABLE jobs ADD COLUMN {column} {column_type}"
            )

    conn.execute("""
        CREATE INDEX IF NOT EXISTS idx_jobs_status_created_at
        ON jobs (status, created_at)
    """)

    conn.commit()
    conn.close()


def create_job(job):
    conn = get_connection()

    try:
        conn.execute("""
            INSERT INTO jobs (
                job_id,
                service_id,
                package,
                hostname,
                customer_username,
                status,
                vm_ip,
                error,
                created_at,
                updated_at,
                os_type,
                num_cpus,
                memory_mb,
                disk_size_gb
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            job["job_id"],
            job["service_id"],
            job["package"],
            job["hostname"],
            job["customer_username"],
            job["status"],
            job.get("vm_ip"),
            job.get("error"),
            job["created_at"],
            job["updated_at"],
            job.get("os_type"),
            job.get("num_cpus"),
            job.get("memory_mb"),
            job.get("disk_size_gb"),
        ))

        conn.commit()

        row = conn.execute(
            "SELECT * FROM jobs WHERE job_id = ?",
            (job["job_id"],)
        ).fetchone()

        if row is None:
            raise RuntimeError("Created job could not be read back")

        return dict(row), True

    except Exception as exc:
        conn.rollback()

        if "UNIQUE constraint failed: jobs.service_id" not in str(exc):
            raise

        row = conn.execute(
            "SELECT * FROM jobs WHERE service_id = ?",
            (job["service_id"],)
        ).fetchone()

        if row is None:
            raise RuntimeError(
                "service_id uniqueness conflict occurred, "
                "but existing job could not be found"
            )

        return dict(row), False

    finally:
        conn.close()


def get_job(job_id):
    conn = get_connection()

    row = conn.execute(
        "SELECT * FROM jobs WHERE job_id = ?",
        (job_id,)
    ).fetchone()

    conn.close()

    if row is None:
        return None

    return dict(row)

def get_job_for_service(service_id):
    conn = get_connection()

    row = conn.execute(
        "SELECT * FROM jobs WHERE service_id = ?",
        (service_id,)
    ).fetchone()

    conn.close()

    if row is None:
        return None

    return dict(row)


def update_job(job_id, **fields):
    allowed_fields = {
        "status",
        "vm_ip",
        "error",
        "updated_at",
    }

    updates = {
        key: value
        for key, value in fields.items()
        if key in allowed_fields
    }

    if not updates:
        return

    set_clause = ", ".join(
        f"{key} = ?"
        for key in updates
    )

    values = list(updates.values())
    values.append(job_id)

    conn = get_connection()

    conn.execute(
        f"""
        UPDATE jobs
        SET {set_clause}
        WHERE job_id = ?
        """,
        values,
    )

    conn.commit()
    conn.close()


def claim_next_job():
    """
    Atomically claim the oldest queued job.

    Returns the claimed job as a dict, or None when no queued
    jobs are available.

    SQLite transaction locking guarantees that two workers
    cannot claim the same queued job.
    """
    conn = get_connection()

    try:
        conn.execute("BEGIN IMMEDIATE")

        row = conn.execute(
            """
            SELECT *
            FROM jobs
            WHERE status = 'queued'
            ORDER BY created_at ASC
            LIMIT 1
            """
        ).fetchone()

        if row is None:
            conn.commit()
            return None

        job_id = row["job_id"]
        updated_at = datetime.now(timezone.utc).isoformat()

        result = conn.execute(
            """
            UPDATE jobs
            SET
                status = 'provisioning',
                updated_at = ?,
                error = NULL
            WHERE job_id = ?
              AND status = 'queued'
            """,
            (updated_at, job_id),
        )

        if result.rowcount != 1:
            conn.rollback()
            return None

        claimed = conn.execute(
            """
            SELECT *
            FROM jobs
            WHERE job_id = ?
            """,
            (job_id,),
        ).fetchone()

        conn.commit()

        if claimed is None:
            return None

        return dict(claimed)

    except Exception:
        conn.rollback()
        raise

    finally:
        conn.close()


def create_management_operation(operation):
    """
    Create a new VPS management operation.

    Expected fields:
        operation_id
        service_id
        operation
        status
        created_at
        updated_at
    """
    conn = get_connection()

    try:
        conn.execute(
            """
            INSERT INTO management_operations (
                operation_id,
                service_id,
                operation,
                status,
                error,
                created_at,
                updated_at,
                started_at,
                finished_at
            )
            VALUES (?, ?, ?, ?, NULL, ?, ?, NULL, NULL)
            """,
            (
                operation["operation_id"],
                operation["service_id"],
                operation["operation"],
                operation.get("status", "queued"),
                operation["created_at"],
                operation["updated_at"],
            ),
        )

        conn.commit()

    finally:
        conn.close()


def get_management_operation(operation_id):
    """
    Return one management operation as a dict.

    Returns None when the operation does not exist.
    """
    conn = get_connection()

    try:
        row = conn.execute(
            """
            SELECT *
            FROM management_operations
            WHERE operation_id = ?
            """,
            (operation_id,),
        ).fetchone()

        if row is None:
            return None

        return dict(row)

    finally:
        conn.close()



def get_latest_management_operation(service_id):
    """
    Return the most recently created management operation
    for a VPS service.

    Returns None when the service has no management operations.
    """
    conn = get_connection()

    try:
        row = conn.execute(
            """
            SELECT *
            FROM management_operations
            WHERE service_id = ?
            ORDER BY created_at DESC
            LIMIT 1
            """,
            (service_id,),
        ).fetchone()

        if row is None:
            return None

        return dict(row)

    finally:
        conn.close()

def has_active_management_operation(service_id):
    """
    Check whether a VPS already has a queued or running
    management operation.

    Returns True or False.
    """
    conn = get_connection()

    try:
        row = conn.execute(
            """
            SELECT 1
            FROM management_operations
            WHERE service_id = ?
              AND status IN ('queued', 'running')
            LIMIT 1
            """,
            (service_id,),
        ).fetchone()

        return row is not None

    finally:
        conn.close()


def update_management_operation(operation_id, **fields):
    """
    Update allowed fields of a management operation.
    """
    allowed_fields = {
        "status",
        "error",
        "updated_at",
        "started_at",
        "finished_at",
    }

    updates = {
        key: value
        for key, value in fields.items()
        if key in allowed_fields
    }

    if not updates:
        return

    set_clause = ", ".join(
        f"{key} = ?"
        for key in updates
    )

    values = list(updates.values())
    values.append(operation_id)

    conn = get_connection()

    try:
        conn.execute(
            f"""
            UPDATE management_operations
            SET {set_clause}
            WHERE operation_id = ?
            """,
            values,
        )

        conn.commit()

    finally:
        conn.close()


def claim_next_management_operation():
    """
    Atomically claim the oldest queued management operation.

    The operation moves from:
        queued -> running

    Returns the claimed operation as a dict,
    or None when no queued operation exists.
    """
    conn = get_connection()

    try:
        conn.execute("BEGIN IMMEDIATE")

        row = conn.execute(
            """
            SELECT *
            FROM management_operations
            WHERE status = 'queued'
            ORDER BY created_at ASC
            LIMIT 1
            """
        ).fetchone()

        if row is None:
            conn.commit()
            return None

        operation_id = row["operation_id"]
        updated_at = datetime.now(timezone.utc).isoformat()
        started_at = updated_at

        result = conn.execute(
            """
            UPDATE management_operations
            SET
                status = 'running',
                updated_at = ?,
                started_at = ?,
                error = NULL
            WHERE operation_id = ?
              AND status = 'queued'
            """,
            (
                updated_at,
                started_at,
                operation_id,
            ),
        )

        if result.rowcount != 1:
            conn.rollback()
            return None

        claimed = conn.execute(
            """
            SELECT *
            FROM management_operations
            WHERE operation_id = ?
            """,
            (operation_id,),
        ).fetchone()

        conn.commit()

        if claimed is None:
            return None

        return dict(claimed)

    except Exception:
        conn.rollback()
        raise

    finally:
        conn.close()
