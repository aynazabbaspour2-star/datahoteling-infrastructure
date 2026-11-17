# DataHoteling — Target Production Architecture

## 1. Purpose

This document proposes the target architecture for transforming DataHoteling
from an experimental infrastructure into a secure, maintainable, scalable,
and commercially operable hosting and VPS platform.

This is a proposed design. Technology choices marked as candidates require
validation before implementation.

No production changes are authorized by this document.

## 2. Architecture Principles

The target platform must follow these principles:

- Clear separation of Hosting and VPS business domains.
- WHMCS remains the customer-facing billing and order-management system.
- Explicit ownership of service lifecycle and operational state.
- Stateless API processes wherever practical.
- Durable persistence for orders, services, jobs, and audit records.
- Asynchronous operations for long-running infrastructure tasks.
- Idempotent operations and recoverable job execution.
- Least-privilege access and secure secret management.
- Infrastructure as Code with versioned and tested configurations.
- Observable operations with metrics, logs, and audit trails.
- Separate Lab, Staging, and Production environments.
- No direct production changes without an approved migration plan.

## 3. Logical Architecture

The platform consists of the following domains:

1. Customer and Billing Integration
2. Hosting Control Domain
3. VPS Control Domain
4. Infrastructure Automation Domain
5. Security and Identity
6. Observability and Operations

WHMCS is the external customer and billing system.
DataHoteling owns the operational state and execution of its infrastructure
services, with clearly defined synchronization responsibilities.

## 4. Customer and Billing Integration

### Responsibilities

- Receive service orders and lifecycle events from WHMCS.
- Validate product and service configuration.
- Initiate provisioning, suspension, termination, and other operations.
- Return operation identifiers and status information.
- Synchronize operational results with WHMCS.
- Prevent duplicate execution of repeated requests.

### Design Requirements

- Authenticate every integration request.
- Validate product identifiers and permitted operations.
- Use idempotency keys for operations that may be retried.
- Record incoming requests and their correlation identifiers.
- Never trust a customer-facing request as direct authorization
  to execute arbitrary infrastructure commands.

WHMCS remains responsible for billing and customer-facing order management.
The DataHoteling platform is responsible for infrastructure execution.

## 5. Hosting Control Domain

### Responsibilities

- Integrate with WHM and cPanel.
- Manage hosting account provisioning.
- Manage suspension, unsuspension, termination, and recovery.
- Coordinate DNS operations with PowerDNS.
- Track hosting operation results.
- Define backup and restore workflows.

### Design Boundaries

- Do not duplicate cPanel account-management functionality unnecessarily.
- Keep Hosting workflows independent from VPS provisioning workflows.
- Define explicit product-to-package mappings.
- Define account ownership and DNS synchronization policies.
- Treat WHM and cPanel as external infrastructure dependencies.

## 6. VPS Control Domain

### Main Components

#### 6.1 VPS API

The API is responsible for:

- Authentication and authorization.
- Request validation.
- Product and configuration validation.
- Creating durable operation records.
- Returning operation identifiers.
- Publishing or scheduling asynchronous work.
- Exposing service and operation status.

The API must not perform long-running VMware operations inside
customer-facing HTTP requests.

#### 6.2 Operational Database

PostgreSQL is the recommended candidate for the operational database.

It should store:

- Customers and service ownership references.
- VPS service instances.
- Product and configuration references.
- Provisioning and management operations.
- Operation state transitions.
- Idempotency records.
- Audit events.
- Reconciliation information.

The database must be the authoritative source for operational state.

SQLite should not remain the final shared operational persistence layer
for a multi-worker production architecture.

#### 6.3 Job Queue

A dedicated message broker is recommended for asynchronous execution.

RabbitMQ is a candidate requiring evaluation.

The queue must support:

- Durable messages where required.
- Acknowledgement after successful processing.
- Retry policies with bounded attempts.
- Dead-letter handling.
- Consumer recovery.
- Message correlation.
- Controlled concurrency.

The queue is not the authoritative source of service state.
The operational database remains authoritative.

A transactional outbox pattern should be evaluated to prevent database
updates and message publication from becoming inconsistent.

#### 6.4 Provisioning Workers

Workers execute long-running provisioning tasks:

- Select and validate a versioned VM image.
- Request infrastructure operations.
- Clone and configure virtual machines.
- Apply network and resource configuration.
- Execute secure bootstrap procedures.
- Verify service health.
- Report operation results.

Workers must support leases, timeouts, retries, and recovery after crashes.

#### 6.5 Management Workers

Management operations include:

- Power on.
- Graceful shutdown.
- Restart.
- Password reset.
- Reinstallation.
- Other explicitly authorized lifecycle operations.

Destructive operations such as reinstallation must have validation,
authorization, audit, and failure-recovery procedures.

## 7. Operation Lifecycle and Reliability

Every asynchronous operation must have:

- A unique operation ID.
- A service ID.
- An idempotency key where applicable.
- A defined operation type.
- A creation timestamp.
- A current state.
- An attempt counter.
- A timeout policy.
- A structured result or error.
- An audit trail.

Proposed operation states:

- accepted
- queued
- running
- succeeded
- failed
- retry_wait
- cancelled
- requires_attention

Allowed state transitions must be explicitly defined.

The implementation must prevent:

- Duplicate VM creation after request retries.
- Multiple workers executing the same operation concurrently.
- Permanent intermediate states after worker crashes.
- Incorrect success reporting when infrastructure validation fails.
- Silent loss of failed operations.

A reconciliation process must compare desired operational state
with observed infrastructure state and identify inconsistencies.

## 8. Infrastructure Automation Domain

### VMware Integration

VMware operations must be isolated behind a provider adapter.

The VPS business logic must not depend directly on low-level VMware
implementation details.

The adapter should expose controlled operations such as:

- Clone VM.
- Configure CPU and memory.
- Configure disks.
- Configure network interfaces.
- Power operations.
- Retrieve VM state.
- Delete VM under an approved lifecycle workflow.

VMware licensing, API capabilities, permissions, and failure behavior
must be validated before selecting the production implementation.

### Terraform

Terraform is responsible for declarative infrastructure operations.

It must not become the application database or business workflow engine.

State ownership, locking, workspace strategy, credentials, and recovery
procedures must be defined before production use.

### Packer

Packer is responsible for building versioned golden images.

Images must have:

- Documented OS versions.
- Security updates.
- Controlled build credentials.
- No temporary builder access.
- No embedded production secrets.
- Version identifiers.
- Build validation.
- A tested rollback strategy.

### Ansible

Ansible is responsible for post-provisioning configuration where appropriate.

Hosting and VPS configuration should use separate inventories,
roles, and execution policies.

## 9. Security Architecture

Required controls:

- Centralized identity and access policies.
- Least-privilege service accounts.
- Secure API authentication.
- Authorization for every management operation.
- SSH host key verification.
- TLS certificate validation.
- Secret storage outside source code and images.
- Credential rotation procedures.
- Restricted network access between components.
- Audit logging for privileged operations.
- Secure backup encryption and access control.
- Dependency and image vulnerability management.

Production secrets must never be committed to Git or printed in logs.

## 10. Observability and Operations

The target platform should provide:

- Application metrics.
- API latency and error metrics.
- Queue depth and processing delay.
- Worker health and job failure metrics.
- VM provisioning duration.
- Infrastructure capacity metrics.
- Centralized application and system logs.
- Operation correlation IDs.
- Security and administrative audit events.
- Alerting for service degradation and capacity thresholds.

Prometheus, Grafana, and a centralized logging solution are candidates.
Alertmanager or an equivalent alerting mechanism should be evaluated.

Monitoring must cover the platform itself and the customer-facing services.

## 11. Deployment Architecture

Environments:

### Lab
- Development and experimentation.
- Disposable test infrastructure.
- No customer workloads.
- Synthetic test data.

### Staging
- Production-like configuration.
- Integration and acceptance testing.
- Release validation.
- Controlled test accounts and workloads.

### Production
- Customer workloads.
- Restricted administrative access.
- Approved deployment process.
- Backup and disaster recovery procedures.
- Monitoring and incident response.

Docker Compose may be used initially for reproducible development
and integration testing.

Production orchestration technology must be selected according to
availability, operational complexity, capacity, and team capabilities.
Kubernetes is not a mandatory prerequisite.

## 12. Data and Backup Strategy

The design must define:

- Database backup frequency.
- Retention policies.
- Encryption.
- Off-host backup storage.
- Restore testing.
- VM backup responsibilities.
- Customer data recovery procedures.
- Recovery Point Objective (RPO).
- Recovery Time Objective (RTO).

A successful backup job must not be considered proof of recoverability.
Restore tests are required.

## 13. Migration Strategy

Migration must be incremental and reversible.

Proposed phases:

1. Approve the target architecture and technology decisions.
2. Build an isolated development environment.
3. Implement the new data model and operation lifecycle.
4. Implement the API and worker execution model.
5. Implement VMware integration and image validation.
6. Implement security and observability controls.
7. Test provisioning, management, failure, and recovery scenarios.
8. Validate WHMCS integration in staging.
9. Define data migration and customer-service continuity procedures.
10. Approve production migration separately.

The experimental implementation must not be replaced in production
until the replacement has passed acceptance testing.

## 14. Decisions Requiring Validation

The following decisions remain open:

- PostgreSQL deployment and high-availability requirements.
- RabbitMQ versus alternative queue technologies.
- VMware licensing and production API capabilities.
- Network and IP address management.
- Storage architecture and VM backup technology.
- Customer isolation and resource quota enforcement.
- Service availability and support commitments.
- RPO and RTO targets.
- Production deployment and orchestration model.
- Payment, suspension, renewal, and termination policies.
- Expected customer count and concurrent provisioning volume.

## 15. Production Readiness Gates

Production approval requires evidence for:

- Functional acceptance tests.
- Failure and recovery tests.
- Security review.
- Backup restoration tests.
- Monitoring and alert validation.
- Capacity and performance tests.
- Documentation and operational runbooks.
- Rollback and incident response procedures.
- Customer lifecycle acceptance tests.

Passing an individual development milestone does not imply production approval.

## 16. Status

Architecture status: Proposed — pending review and approval.

No technology selection in this document is an authorization
to modify the existing production infrastructure.
