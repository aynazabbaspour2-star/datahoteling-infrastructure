# DataHoteling — Current Architecture and Gap Analysis

## 1. Purpose

This document describes the currently observed DataHoteling infrastructure,
identifies architectural and operational gaps, and establishes the baseline
for designing a production-ready hosting and VPS platform.

The current implementation is considered an experimental system.
Its existence or successful execution does not imply production readiness.

This document is an assessment, not an approval for commercial deployment.

## 2. Assessment Principles

The assessment distinguishes between:

- Observed: supported by previous repository or server inspections.
- Gap: a known limitation or architectural concern.
- Unverified: requires additional evidence.
- Target decision: must be decided during target architecture design.

No production changes are authorized by this document.

## 3. Current Infrastructure Overview

The currently identified infrastructure includes:

- VMware ESXi as the virtualization layer.
- AlmaLinux hosting server.
- cPanel and WHM for shared hosting management.
- WHMCS for customer orders, billing, and service management.
- PowerDNS for DNS management.
- Custom VPS provisioning API.
- Provisioning and management workers.
- Terraform for VMware infrastructure definitions.
- Packer for Ubuntu and AlmaLinux image builds.
- Ansible for limited host configuration.
- GitHub repository for infrastructure code and documentation.

The README describes a layered architecture, but some documented capabilities
are planned or incomplete rather than fully implemented.

## 4. Hosting Architecture

### 4.1 Observed Components

- WHMCS manages hosting products and customer-facing service workflows.
- WHM provides hosting packages and server administration.
- cPanel provides individual hosting accounts.
- PowerDNS provides authoritative DNS functionality.
- WHMCS has registered cPanel and custom VPS server configurations.

The existing WHM and WHMCS inventory is documented in:

`docs/hosting/whm/whm-inventory.md`

### 4.2 Known Gaps

- Hosting product-to-package and server-group assignments require a clearly
  defined and tested operational policy.
- The boundary between WHMCS automation and custom provisioning logic must
  be documented.
- Hosting provisioning failure handling and reconciliation need a defined
  operational model.
- Backup, restore, account recovery, and disaster recovery procedures have
  not yet been established in this architecture assessment.

### 4.3 Target Decisions

- Define the supported hosting product lifecycle.
- Define account creation, suspension, termination, and recovery workflows.
- Define DNS ownership and synchronization responsibilities.
- Define backup and restore objectives.

## 5. VPS Provisioning Architecture

### 5.1 Observed Components

The existing VPS workflow includes:

1. WHMCS receives a VPS order.
2. The custom WHMCS module communicates with the provisioning API.
3. The API stores provisioning jobs in SQLite.
4. The provisioning worker processes queued jobs.
5. Terraform interacts with VMware.
6. The selected golden image is cloned.
7. Bootstrap and health-check scripts configure and validate the VPS.
8. The WHMCS reconciler periodically retrieves job status.

Management operations are handled by a separate worker.

Detailed findings are documented in:

`docs/provisioning/provisioning-inventory.md`

### 5.2 Known Gaps

- SQLite currently combines operational persistence and queue-related
  responsibilities.
- There is no complete stale-job recovery mechanism.
- A worker interruption can leave jobs or management operations in
  intermediate states.
- Provisioning and management workers use different Python environments.
- Management worker deployment definitions are not fully represented
  in the repository.
- Reinstall operations have destructive failure scenarios.
- SSH host key verification is disabled in the observed worker command.
- Secret cleanup and retry behavior need stronger lifecycle guarantees.
- API, worker, database, and VMware responsibilities need clearer boundaries.
- Idempotency and duplicate request handling require a formal design.

### 5.3 Target Decisions

- Define the provisioning state machine.
- Define retry, timeout, cancellation, and recovery behavior.
- Define job ownership and concurrency rules.
- Define idempotency keys and duplicate request handling.
- Define transactional boundaries between the API, database, and workers.
- Define safe reinstall and rollback procedures.
- Define service-level objectives for provisioning operations.

## 6. VMware and Infrastructure Automation

### 6.1 Terraform

The repository contains separate Lab and Production environments.

The Lab environment contains VM provisioning definitions and a reusable
VM module.

The Production environment is documented as discovery-oriented because
the current ESXi licensing model restricts certain API write operations.

### 6.2 Packer

Two image factories exist:

- AlmaLinux
- Ubuntu

Previous inspection identified differences between their account setup,
SSH configuration, cleanup procedures, and provisioning-user preparation.

Both configurations also have TLS verification concerns that must be
addressed before production use.

The Ubuntu Packer configuration has an unresolved provisioning public-key
input requirement.

### 6.3 Ansible

The current Ansible playbook targets the `cpanel` inventory group.

The observed roles provide:

- Common packages, timezone, and Chrony configuration.
- SSH-related security configuration.

A complete VPS-specific configuration workflow has not been established.

### 6.4 Known Gaps

- Golden image requirements are not standardized across operating systems.
- Temporary build accounts and privileges require consistent cleanup.
- The provisioning SSH identity must be consistently installed and managed.
- Terraform state, locking, and environment isolation require a production
  design.
- Ansible responsibilities need to be separated by machine role.
- The actual Lab and Production execution boundaries require enforcement.

## 7. Application Runtime and Data

### 7.1 Observed State

- The API runs as a systemd service.
- Provisioning and management workers run as separate systemd services.
- SQLite stores provisioning jobs and management operations.
- Runtime secrets are stored under a protected directory in `/run`.
- Python dependencies are not fully pinned through a unified lock strategy.

### 7.2 Known Gaps

- No formal database migration strategy has been established.
- Database backup and recovery objectives are not defined.
- Queue recovery is incomplete.
- Runtime secret persistence and reboot behavior need explicit handling.
- Logging, metrics, tracing, and audit events need a unified design.
- Dependency versions and reproducible builds need improvement.

## 8. Security Findings

Previous inspections identified the following concerns:

- Packer configurations disable vSphere TLS verification.
- SSH host key verification is disabled in the provisioning worker.
- Golden image build accounts and sudo privileges are not consistently
  removed.
- Ubuntu image preparation and cleanup are incomplete.
- Secret lifecycle and failure cleanup need improvement.
- Some database backup files were observed with permissive file permissions.
- A Packer password was exposed in terminal output during an earlier audit
  and must be treated as compromised.

The exposed credential must be rotated before production use.
No credential values belong in this document or in Git.

## 9. Monitoring and Operations

The repository contains a monitoring directory, but no tracked monitoring
configuration was found during this assessment.

Prometheus and Grafana have been used in a separate monitoring lab, but
their production integration with DataHoteling has not been established.

The following operational capabilities remain to be designed:

- Centralized logs.
- Metrics and service health.
- Alert routing and escalation.
- Audit trails.
- Backup monitoring.
- Provisioning failure alerts.
- Capacity and resource monitoring.
- Incident response procedures.

Loki and Alertmanager are mentioned in the README as intended components,
not as verified production deployments.

## 10. Repository and Deployment Gaps

The repository contains Terraform, Packer, Ansible, provisioning code,
WHMCS customizations, systemd templates, and a security-check script.

Previous inspections identified discrepancies between some deployed
systemd units and repository deployment definitions.

The repository does not yet provide a complete reproducible deployment
workflow for all application services.

No Dockerfile or Compose configuration was found in the inspected
tracked-file inventory.

## 11. Architecture Gap Summary

| Area | Current State | Required Direction |
|---|---|---|
| Hosting | WHM/cPanel and WHMCS exist | Define reliable service lifecycle |
| VPS API | Experimental implementation | Define stable API boundaries |
| Job processing | SQLite-backed workers | Design durable queue and recovery |
| Database | SQLite | Evaluate production database requirements |
| VMware | Terraform Lab and Production | Enforce safe environment boundaries |
| Golden Images | Ubuntu and AlmaLinux factories | Standardize image lifecycle |
| Configuration | Limited Ansible roles | Define role-specific automation |
| Security | Several identified gaps | Establish security baseline |
| Secrets | Runtime file-based handling | Define centralized lifecycle |
| Monitoring | No tracked production configuration | Design observability |
| Deployment | Partial systemd definitions | Reproducible deployment |
| CI/CD | Not fully assessed | Define build, test, and release pipeline |
| Docker | Not implemented | Design after architecture decisions |

## 12. Components to Preserve, Redesign, or Evaluate

### Preserve as Existing Capabilities

Subject to validation and redesign:

- WHMCS product and customer workflows.
- cPanel and WHM hosting integration.
- VMware infrastructure definitions.
- Existing provisioning business logic.
- Existing WHMCS custom module functionality.

### Redesign

- VPS provisioning lifecycle.
- Job processing and recovery.
- Database and queue architecture.
- Secret management.
- Golden image build and cleanup.
- Worker deployment and runtime configuration.
- Monitoring and operational workflows.

### Evaluate Before Selecting

- SQLite versus a production relational database.
- Dedicated message broker versus database-backed job processing.
- Monolithic application versus separated services.
- Container deployment boundaries.
- Centralized logging and monitoring stack.
- Backup and disaster recovery architecture.

No technology selection is implied by this assessment.

## 13. Target Production Architecture — Pending Design

The target architecture must define the following logical layers:

1. Customer and billing layer.
2. Hosting control and provisioning layer.
3. VPS orchestration and API layer.
4. Durable job processing layer.
5. Database and state management layer.
6. VMware and virtualization layer.
7. Golden image and configuration layer.
8. Security and secret management layer.
9. Monitoring, logging, and audit layer.
10. CI/CD and environment promotion layer.

The detailed component choices, interfaces, deployment topology, and
failure-handling policies will be documented separately.

## 14. Required Design Decisions

The following decisions are still open:

- What is the authoritative source of service state?
- Which database should store customer service and provisioning state?
- How should jobs be queued, retried, recovered, and cancelled?
- How should API and worker services authenticate?
- How should secrets be issued, delivered, rotated, and revoked?
- How should VPS reinstall and rollback work?
- How should hosting and VPS provisioning be isolated?
- How should Lab, Staging, and Production be separated?
- Which services should run in containers?
- What monitoring and backup objectives are required?

## 15. Readiness Assessment

The current implementation is an experimental foundation, not a
commercially approved hosting platform.

Dockerization must not be treated as a substitute for resolving
architectural, security, data integrity, and operational gaps.

Production readiness requires:

- Approved target architecture.
- Implemented and tested provisioning lifecycle.
- Reliable recovery and rollback.
- Security remediation.
- Reproducible deployment.
- Monitoring and operational procedures.
- Backup and disaster recovery validation.
- End-to-end acceptance testing.

## 16. Assessment Boundaries

This document is based on repository inspection and previously observed
server configuration.

It does not certify:

- Production security.
- Customer data integrity.
- Successful disaster recovery.
- VMware high availability.
- Commercial service readiness.
- End-to-end provisioning reliability.

These require dedicated implementation and validation stages.
