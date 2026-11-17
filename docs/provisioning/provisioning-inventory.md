# DataHoteling Provisioning Infrastructure Inventory

## 1. Scope

This document records the observed architecture and operational characteristics
of the DataHoteling VPS provisioning system.

The purpose is to establish a safe baseline for future deployment automation
and Dockerization.

This is an inventory, not an authorization to modify production services.

No production configuration, credentials, customer records, database files,
private keys, or environment variable values are included.

## 2. High-Level Architecture

The provisioning platform consists of:

1. Provisioning API
2. Provisioning Queue Worker
3. Management Queue Worker
4. SQLite provisioning database
5. Secret-file handling
6. VMware/vSphere integration through Terraform and pyVmomi
7. VPS bootstrap and health-check scripts
8. WHMCS custom VPS module
9. WHMCS VPS Reconciler

The API and workers run as separate systemd services.

The Reconciler is a PHP script integrated with WHMCS and scheduled by a
systemd timer.

## 3. Application Components

### 3.1 Provisioning API

Source:
- `provisioning/api/app.py`
- `provisioning/api/db.py`
- `provisioning/api/profiles.py`
- `provisioning/api/secrets.py`

Runtime:
- Python 3.9
- Virtual environment: `.venv`
- Uvicorn
- FastAPI

Observed execution:
- Module: `provisioning.api.app:app`
- Bind address: `127.0.0.1`
- Port: `8099`

The API listens on loopback rather than directly exposing its port on all
network interfaces.

The API uses SQLite for provisioning job and management-operation records.

### 3.2 Provisioning Queue Worker

Source:
- `provisioning/worker/worker.py`

Runtime:
- Python 3.9
- Virtual environment: `.venv`

Main responsibilities:
- Claim queued provisioning jobs.
- Resolve VPS configuration.
- Select or create a Terraform workspace.
- Apply the infrastructure configuration.
- Obtain the VM IP address.
- Run the VPS bootstrap script.
- Run the health-check script.
- Update the job status.

Observed Terraform workspace naming:
- `svc-{service_id}`

The worker polls the queue approximately every five seconds.

Terraform apply has an observed timeout of 900 seconds.

### 3.3 Management Queue Worker

Source:
- `provisioning/management/management_worker.py`

Runtime:
- Python 3.12
- Virtual environment: `.venv-vsphere`
- pyVmomi

Supported operations observed in the code:
- `change_password`
- `reinstall`
- `power_on`
- `power_shutdown`
- `power_restart`

The worker polls the management-operation queue approximately every five
seconds.

The Management Worker uses a different Python environment from the API and
Provisioning Worker. Its dependencies and runtime must therefore be managed
independently during containerization.

## 4. Python Dependencies

### API and Provisioning Worker

Tracked requirements file:
- `provisioning/api/requirements.txt`

Declared dependencies:
- fastapi
- uvicorn[standard]
- pydantic

The requirements are not version-pinned.

The observed production Python environment also contains transitive and
additional installed packages. A reproducible dependency lock or constraints
file has not yet been established.

### Management Worker

Observed runtime:
- Python 3.12
- pyvmomi

The observed Management Worker virtual environment contains pyvmomi 9.1.1.0.

A dedicated tracked requirements file for the Management Worker has not been
identified.

### Dependency management gaps

Before building production images:
- Define dependencies separately for each runtime.
- Pin and validate dependency versions.
- Establish reproducible installation procedures.
- Test application compatibility with the selected Python base images.
- Avoid copying existing virtual environments into container images.

## 5. Systemd Services

Three application services were observed:

| Service | Runtime | Environment file |
|---|---|---|
| datahoteling-provisioning-api | Python 3.9 | API environment file |
| datahoteling-provisioning-worker | Python 3.9 | Worker environment file |
| datahoteling-management-worker | Python 3.12 | Worker environment file |

The API and Provisioning Worker have tracked templates under:
- `deploy/systemd/`

The Management Worker has a live systemd unit, but no corresponding tracked
template was found in `deploy/systemd/`.

The Provisioning Worker also has a live graceful-shutdown drop-in that was not
found in the tracked deployment templates.

The API and Provisioning Worker use separate systemd RuntimeDirectory settings.

The Management Worker does not currently declare a RuntimeDirectory.

The two workers use the same EnvironmentFile in the observed configuration.
Whether all variables are required by both workers has not been established.

The current systemd templates contain absolute production paths. A reusable
deployment design will need configurable paths or an installation mechanism.

## 6. SQLite Database

Database source:
- `provisioning/api/db.py`

Observed database path is derived from the source directory and points to:
- `provisioning/api/provisioning.db`

The database is not tracked by Git.

SQLite configuration observed in the application:
- Connection timeout: 5 seconds
- Busy timeout: 5000 milliseconds
- Foreign keys enabled
- WAL journal mode
- Synchronous mode: NORMAL

### 6.1 Jobs table

Observed columns:

| Column | Type |
|---|---|
| job_id | TEXT PRIMARY KEY |
| service_id | INTEGER NOT NULL |
| package | TEXT NOT NULL |
| hostname | TEXT NOT NULL |
| customer_username | TEXT NOT NULL |
| status | TEXT NOT NULL |
| vm_ip | TEXT |
| error | TEXT |
| created_at | TEXT NOT NULL |
| updated_at | TEXT NOT NULL |
| os_type | TEXT |
| num_cpus | INTEGER |
| memory_mb | INTEGER |
| disk_size_gb | INTEGER |

### 6.2 Management operations table

Observed columns:

| Column | Type |
|---|---|
| operation_id | TEXT PRIMARY KEY |
| service_id | INTEGER NOT NULL |
| operation | TEXT NOT NULL |
| status | TEXT NOT NULL |
| error | TEXT |
| created_at | TEXT NOT NULL |
| updated_at | TEXT NOT NULL |
| started_at | TEXT |
| finished_at | TEXT |

### 6.3 Database operational considerations

- The database uses SQLite WAL mode.
- WAL and shared-memory sidecar files may exist while the database is active.
- Database files and backups must remain outside Git.
- Backups require appropriate restrictive permissions.
- Container storage must be persistent.
- Backup and restore procedures must account for SQLite WAL consistency.
- Concurrent access and locking behavior must be tested before changing the
  database architecture.

A future move to a network database should be treated as a separate migration,
not as an automatic consequence of Dockerization.

## 7. Queue Processing and Recovery

Both queue claim functions use SQLite `BEGIN IMMEDIATE` transactions.

The provisioning worker claims queued jobs by changing their status to
`provisioning`.

The management worker claims queued operations by changing their status to
`running`.

The conditional update and row-count check help prevent two workers from
claiming the same queued record concurrently.

However, atomic claiming does not provide exactly-once execution.

### Recovery gap

No stale-job or stale-operation recovery mechanism was identified in the
audited Python source.

If a process crashes after claiming a job or operation, the record may remain
in `provisioning` or `running`.

Systemd restarting a process does not automatically recover those records.

Before production Dockerization, design and test:
- Stale-job detection.
- Stale-operation detection.
- Safe retry rules.
- Idempotency for infrastructure operations.
- Manual recovery procedures.
- Protection against duplicate VM creation or destructive retries.

Do not automatically reset all stale records to queued without verifying
their actual VMware state.

## 8. Secret Handling

Source:
- `provisioning/api/secrets.py`

Observed default secret directory:
- `/run/datahoteling-provisioning/secrets`

The directory and secret files are designed to use restrictive permissions.

Observed behavior:
- Secret files are created exclusively.
- File data is flushed and synchronized.
- Secret files are read by workers and deleted after use.
- The API and workers use the same configured secret directory.

The API, Provisioning Worker, and Management Worker have all been observed
with the same secret-directory environment setting.

### Risks and design requirements

- `/run` is volatile runtime storage and may be cleared on reboot.
- The API has a systemd RuntimeDirectory configuration with
  RuntimeDirectoryPreserve disabled.
- The workers and API use different RuntimeDirectory declarations.
- The shared secret path must be verified against service startup and shutdown
  behavior.
- A secret consumed by a failed operation may not be available for retry.
- Python assigning `None` to a password variable does not guarantee secure
  memory erasure.

For Docker:
- Never bake credentials or private keys into images.
- Use controlled secret injection or read-only secret mounts.
- Define ownership and permissions explicitly.
- Ensure all containers that need a secret can access it safely.
- Define secret expiry and cleanup behavior.
- Do not use ordinary persistent application volumes for temporary passwords
  unless the security design explicitly requires it.

## 9. VMware and Terraform Integration

The Provisioning Worker uses Terraform for VPS creation.

The Management Worker uses pyVmomi for VMware management operations.

The two execution paths have different dependencies and runtimes.

The Terraform workspace naming observed in the Provisioning Worker is based
on the service identifier.

Before containerization:
- Identify Terraform binary and provider requirements.
- Identify provider plugin caching requirements.
- Define access to Terraform state.
- Define workspace isolation and locking.
- Inject VMware credentials securely.
- Determine how the Management Worker obtains VMware connectivity.
- Test concurrent operations and failure recovery.
- Keep Terraform state outside disposable container filesystems.

## 10. VPS Bootstrap and Health Checks

Tracked scripts:
- `provisioning/provision-vps.sh`
- `provisioning/scripts/bootstrap-vps.sh`
- `provisioning/scripts/health-check.sh`

The Provisioning Worker transfers and executes the bootstrap script on the
target VPS.

The bootstrap process configures the VPS hostname, customer account,
password, SSH password-authentication setting, and related account setup.

The script expects some provisioning prerequisites to exist in the target
image. The audited bootstrap script does not itself establish every SSH
provisioning prerequisite.

The golden-image configuration must therefore be audited separately,
including:
- Provisioning account.
- Authorized SSH key.
- Sudo permissions.
- SSH server configuration.
- Base operating-system packages.

The SSH client currently disables host-key verification using
StrictHostKeyChecking=no and UserKnownHostsFile=/dev/null.

This creates a host-identity verification risk. A future design should use
controlled host-key provisioning and known_hosts management.

The bootstrap process sends the customer password through standard input
rather than placing it directly in the command-line arguments.

Remote temporary-file cleanup should be reviewed: an exception before the
cleanup code is reached can leave the uploaded bootstrap script on the target
VM.

## 11. Management Operations and Reinstall Risks

The reinstall workflow creates a replacement VM from a golden image, performs
bootstrap and health checks, and then begins a handoff from the old VM to the
new VM.

Important observed characteristics:
- The initial health check occurs before the final handoff.
- The old VM may be destroyed before all final handoff steps complete.
- The final VM is not subjected to the same health check after final power-on.
- A failure after handoff begins may leave the replacement VM in an
  intermediate state.
- The main provisioning job and management-operation record have separate
  status fields.
- A failed management operation does not necessarily update the main job
  record.

These workflows need explicit recovery, rollback, and state-reconciliation
design before production deployment changes.

## 12. WHMCS VPS Reconciler

Source:
- `whmcs/modules/servers/datahotelingvps/bin/reconcile.php`

The Reconciler is a PHP script integrated with WHMCS.

Observed runtime:
- PHP CLI 8.2.33
- ionCube Loader 13.3.1
- PHP cURL
- PDO
- PDO MySQL
- mysqli
- OpenSSL
- JSON

The script loads the WHMCS `init.php` file and uses WHMCS database and service
classes.

It reads the API server record from WHMCS, decrypts its stored token using
WHMCS facilities, and calls the provisioning API using a Bearer token.

The API port is defined in the script.

The Reconciler reads provisioning job status and updates corresponding
WHMCS service properties.

It does not create VMs or independently recover stuck provisioning jobs.

### Scheduling

The Reconciler is run by a systemd oneshot service and a systemd timer.

Observed timer behavior:
- First run after boot: 30 seconds.
- Subsequent interval: one minute.
- Persistent timer behavior enabled.

The live Reconciler service and timer were not found as tracked templates under
`deploy/systemd/`.

### Reconciler deployment requirements

The Reconciler depends on:
- WHMCS source and initialization.
- WHMCS configuration and encryption facilities.
- WHMCS database connectivity.
- PHP CLI.
- PHP cURL.
- Compatible ionCube Loader where required by the WHMCS environment.

It should not be treated as an independent PHP script with no WHMCS runtime
dependencies.

The current script contains an absolute WHMCS initialization path and a
fixed WHMCS API server record identifier.

The API URL scheme is selected using the WHMCS server secure setting.
The transport configuration must be verified to ensure Bearer tokens are
never sent over an untrusted plaintext network.

For Dockerization, decide whether the Reconciler runs:
- Within the WHMCS PHP runtime; or
- In a separately managed PHP container with controlled access to the
  required WHMCS files, configuration, database, and encryption facilities.

The Reconciler scheduling mechanism must also be redesigned for the selected
deployment architecture.

## 13. Deployment Files and Repository Gaps

Tracked systemd templates currently include:
- `deploy/systemd/datahoteling-provisioning-api.service`
- `deploy/systemd/datahoteling-provisioning-worker.service`

Live systemd configuration was also observed for:
- Management Worker service.
- Reconciler service.
- Reconciler timer.
- Provisioning Worker graceful-shutdown drop-in.

Corresponding tracked templates or drop-in files were not found for all of
these live configurations.

The environment files are excluded from Git and must remain outside source
control.

The current deployment templates use absolute production paths and should
not be assumed to be portable to another host.

## 14. Dockerization Readiness Requirements

The following work remains necessary before a production Docker deployment:

1. Define separate images or runtime environments for Python 3.9 and Python
   3.12 workloads.
2. Pin and lock Python dependencies.
3. Define the PHP 8.2 and ionCube compatibility strategy for WHMCS/Reconciler.
4. Define persistent storage and backup procedures for SQLite.
5. Design stale queue and operation recovery.
6. Design safe retries and idempotency for Terraform and VMware actions.
7. Define secure secret injection and shared-secret access.
8. Replace disabled SSH host-key verification with controlled verification.
9. Audit the VPS golden image and its provisioning account prerequisites.
10. Improve reinstall handoff, rollback, and post-handoff health checks.
11. Create reproducible templates for all required services and schedules.
12. Replace hardcoded production paths with configurable deployment settings.
13. Define network boundaries and API authentication between services.
14. Test container restart, host reboot, storage recovery, and interrupted
    provisioning scenarios.
15. Document operational recovery and backup/restore procedures.

## 15. Audit Boundaries

This inventory records observed source code and runtime configuration.

It does not establish that every historical job, VM, or customer service is
in a consistent state.

No production service was modified as part of this audit.

No credentials, environment variable values, private keys, database contents,
customer identifiers, customer IP addresses, or production secrets are
intentionally included in this document.

Any future production change requires a separate impact assessment and
explicit approval.
