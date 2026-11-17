# DataHoteling — VPS Data Model and State Machine

## 1. Purpose

This document defines the proposed data model and lifecycle state machines
for the redesigned DataHoteling VPS Control Plane.

The design is independent of the experimental implementation.

PostgreSQL is the proposed operational database.

This document is a design proposal. It does not authorize production changes.

## 2. Core Design Principles

- Separate commercial service state from VM runtime state.
- Separate service records from asynchronous operations.
- Keep the database as the authoritative source of operational state.
- Never assume that a successful API response means a VM operation succeeded.
- Every infrastructure operation must be traceable.
- Repeated requests must not create duplicate infrastructure resources.
- Workers must be able to recover after interruption.
- Destructive operations require explicit authorization and audit records.
- VMware state must be periodically reconciled with database state.

## 3. Main Domain Entities

### 3.1 Customer Reference

Represents the customer associated with a VPS.

Proposed fields:

- id: internal UUID.
- whmcs_client_id: external WHMCS client identifier.
- created_at.
- updated_at.

The WHMCS client ID must be unique.

Customer billing data remains owned by WHMCS.

### 3.2 Product Offering

Defines the VPS product configuration available for purchase.

Proposed fields:

- id: internal UUID.
- code: unique product code.
- name.
- vcpu.
- memory_mb.
- disk_gb.
- bandwidth_limit.
- operating_system_family.
- image_policy.
- is_active.
- created_at.
- updated_at.

Product definitions must be versioned or snapshotted when assigned to a service.
Changing a product must not silently change existing customer VPS resources.

### 3.3 VPS Service

Represents the customer's purchased VPS service.

Proposed fields:

- id: internal UUID.
- customer_id: reference to customer.
- whmcs_service_id: external WHMCS service identifier.
- product_id: reference to product offering.
- service_state.
- desired_power_state.
- runtime_state.
- hostname.
- primary_ip_address.
- region_or_cluster.
- resource_snapshot: immutable configuration snapshot.
- created_at.
- updated_at.
- terminated_at.

Constraints:

- whmcs_service_id must be unique.
- A service must belong to one customer.
- A service must have a valid product configuration.
- Terminated services must not be silently reactivated.
- Resource changes must be explicitly recorded.

### 3.4 VM Resource Binding

Maps a VPS service to its infrastructure resource.

Proposed fields:

- id: internal UUID.
- service_id: reference to VPS service.
- provider_type.
- provider_instance_id.
- provider_template_id.
- cluster_id.
- datastore_id.
- network_id.
- last_observed_state.
- last_observed_at.
- created_at.
- updated_at.

Constraints:

- A provider instance must not be assigned to multiple active services.
- Provider identifiers must be unique within their provider scope.
- Deletion of a VM binding must be audited.

### 3.5 Operation

Represents an asynchronous request against a VPS service.

Proposed fields:

- id: internal UUID.
- service_id: reference to VPS service.
- operation_type.
- operation_state.
- idempotency_key.
- requested_by.
- request_payload.
- result_payload.
- error_code.
- error_message.
- attempt_count.
- max_attempts.
- scheduled_at.
- started_at.
- completed_at.
- created_at.
- updated_at.

Constraints:

- An idempotency key must be unique within its defined scope.
- Operation payloads must be validated before execution.
- Sensitive credentials must never be stored in plaintext payloads.
- Every operation must reference an existing service.

### 3.6 Operation Attempt

Records each execution attempt independently.

Proposed fields:

- id: internal UUID.
- operation_id: reference to operation.
- attempt_number.
- worker_id.
- started_at.
- finished_at.
- outcome.
- error_code.
- sanitized_error_details.

This table provides an execution history without overwriting earlier failures.

### 3.7 Idempotency Record

Prevents duplicate execution of repeated external requests.

Proposed fields:

- id: internal UUID.
- scope.
- idempotency_key.
- request_hash.
- operation_id.
- response_status.
- created_at.
- expires_at.

The same key with a different request hash must be rejected.

### 3.8 Outbox Event

Stores events that must be published to the message broker.

Proposed fields:

- id: internal UUID.
- aggregate_type.
- aggregate_id.
- event_type.
- event_payload.
- created_at.
- published_at.
- publish_attempts.

The event and associated database state change must be committed
in the same database transaction.

### 3.9 Audit Event

Records security-sensitive and administrative actions.

Proposed fields:

- id: internal UUID.
- actor_type.
- actor_id.
- action.
- resource_type.
- resource_id.
- correlation_id.
- sanitized_details.
- created_at.

Audit records must not contain passwords, API tokens, or private keys.

## 4. Relationships

Proposed logical relationships:

- One customer can own many VPS services.
- One product offering can be assigned to many VPS services.
- One VPS service can have one active VM resource binding.
- One VPS service can have many operations.
- One operation can have many execution attempts.
- One operation can generate multiple audit events.
- One operation can generate one or more outbox events.

Foreign keys and unique constraints must enforce these relationships.

## 5. VPS Service State Machine

Service state describes the commercial and operational lifecycle
of the customer's VPS service.

Proposed states:

- pending: service record created, provisioning not started.
- provisioning: initial VM creation is in progress.
- active: service is provisioned and accepted for customer use.
- suspending: suspension is in progress.
- suspended: service is suspended.
- unsuspending: restoration from suspension is in progress.
- terminating: termination is in progress.
- terminated: service has been permanently terminated.
- failed: initial provisioning failed.
- requires_attention: automated processing cannot safely continue.

Proposed transitions:

- pending -> provisioning
- provisioning -> active
- provisioning -> failed
- provisioning -> requires_attention
- failed -> provisioning (authorized retry)
- active -> suspending
- suspending -> suspended
- suspending -> requires_attention
- suspended -> unsuspending
- unsuspending -> active
- unsuspending -> requires_attention
- active -> terminating
- suspended -> terminating
- terminating -> terminated
- terminating -> requires_attention

A terminated service is terminal.
Reactivation must create a new service or follow an explicitly approved
business process.

A failed or requires_attention service must not be reported as active.

## 6. VM Runtime State

Runtime state describes the last observed infrastructure state.

Proposed states:

- unknown
- powered_on
- powered_off
- suspended
- starting
- stopping
- rebooting
- unavailable
- not_found

Runtime state must be based on VMware observations, not merely on
the success response of an API request.

Runtime state is independent from service_state.

For example:

- service_state=active and runtime_state=powered_off is valid.
- service_state=suspended and runtime_state=powered_off may be valid.
- service_state=active and runtime_state=not_found requires reconciliation
  and investigation.

The system must store the observation timestamp.
A stale observation must not be presented as confirmed current state.

## 7. Operation State Machine

Proposed operation states:

- accepted
- queued
- running
- retry_wait
- succeeded
- failed
- cancelled
- requires_attention

Proposed transitions:

- accepted -> queued
- accepted -> cancelled
- queued -> running
- queued -> cancelled
- running -> succeeded
- running -> failed
- running -> retry_wait
- running -> requires_attention
- retry_wait -> queued
- retry_wait -> cancelled

Terminal states:

- succeeded
- failed
- cancelled
- requires_attention

A new operation must be created for a new user request.
Completed operation records must not be reused.

A worker must claim an operation atomically.
Only one valid worker lease may own an operation at a time.

Worker leases must include an expiration time and ownership identifier.

Expired leases must be recovered by a controlled scheduler.
Recovery must verify the actual infrastructure state before repeating
a potentially destructive action.

## 8. Operation Types

Initial supported operation types:

- create
- power_on
- power_off
- restart
- reset_password
- reinstall
- suspend
- unsuspend
- terminate

Each operation type must define:

- Preconditions.
- Required authorization.
- Allowed service states.
- Expected runtime states.
- Timeout.
- Retry policy.
- Whether the action is destructive.
- Post-operation health checks.
- Compensation or recovery behavior.

Reinstall and terminate require stronger authorization and explicit
confirmation than ordinary power operations.

## 9. Idempotency and Concurrency

- External create requests must include an idempotency key.
- Duplicate requests with the same key and request hash return the
  existing operation result.
- Reuse of a key with a different request hash is rejected.
- Database transactions must protect state transitions.
- Workers must use atomic operation claiming.
- Service-level concurrency rules must prevent conflicting operations.
- A power operation must not race with reinstall or termination.
- A lease expiration alone must not prove that the previous worker stopped.

## 10. Failure and Recovery Rules

When a worker crashes:

1. Its lease eventually expires.
2. A recovery process identifies the expired operation.
3. The system inspects the current operation and service records.
4. The system queries VMware for the actual VM state.
5. It determines whether the previous action completed.
6. It either marks success, schedules a safe retry, or requires attention.

The system must not blindly repeat VM creation, reinstall, or termination.

Unknown infrastructure outcomes must be treated as uncertain,
not as successful or safely retryable.

## 11. Reconciliation

A reconciliation process periodically compares:

- Desired service state.
- Stored service state.
- VM resource binding.
- Observed VMware state.
- Pending or running operations.

It must identify:

- Missing VMs.
- Unexpected VMs.
- Stale runtime observations.
- Operations stuck beyond their timeout.
- State mismatches.
- Orphaned resources.

Reconciliation must initially report discrepancies without destructive
automatic correction.

Any automatic corrective action requires a separately approved policy.

## 12. Database Integrity and Security

- Use UUID primary keys for internal entities.
- Use foreign keys and unique constraints.
- Store timestamps in UTC.
- Use transactions for related state changes.
- Use JSONB only for variable or provider-specific payloads.
- Keep core lifecycle fields relational and constrained.
- Never store plaintext passwords or private keys.
- Encrypt sensitive data when persistent storage is unavoidable.
- Apply least-privilege database roles.
- Define retention and backup policies.
- Test database restoration.

## 13. Initial Implementation Boundaries

The first implementation milestone should include:

- Customer reference.
- Product offering.
- VPS service.
- VM resource binding.
- Operation.
- Operation attempt.
- Idempotency record.
- Outbox event.
- Audit event.

The initial implementation must support create, power operations,
and safe failure recovery before adding more complex lifecycle features.

## 14. Decisions Requiring Review

The following require explicit design review:

- Whether customers are managed locally or referenced only from WHMCS.
- Whether product snapshots use relational columns, JSONB, or both.
- Whether IP address allocation is managed in this platform.
- Whether a service may have multiple VM bindings during migration.
- Exact suspension and termination policies.
- Exact retry limits and operation timeouts.
- Lease duration and worker heartbeat interval.
- Whether password reset uses one-time credentials or a secure guest agent.
- VMware observation frequency and reconciliation policy.
- Data retention and audit retention requirements.

## 15. Status

Design status: Proposed — pending review.

No database migration, service deployment, or production change
is authorized by this document.
