# DataHoteling — PostgreSQL Schema Design

## 1. Purpose

This document defines the proposed relational schema for the redesigned
DataHoteling VPS Control Plane.

PostgreSQL is the proposed operational database.

This is a design specification, not an executable migration.
No existing database or production service is modified.

## 2. Database Design Principles

- PostgreSQL is the authoritative operational data store.
- WHMCS remains the owner of billing and customer account data.
- Internal entities use UUID primary keys.
- External identifiers are stored separately.
- All timestamps use TIMESTAMPTZ and UTC.
- Core lifecycle states use constrained relational columns.
- JSONB is reserved for variable configuration and provider payloads.
- Foreign keys enforce entity relationships.
- Unique constraints prevent duplicate resources and requests.
- Transactions protect related state changes.
- Secrets and plaintext credentials are never stored in operation payloads.
- Historical operation attempts and audit records are retained according
  to an approved retention policy.

## 3. Proposed Database Tables

### 3.1 customers

Stores the local reference to a customer managed by WHMCS.

Columns:

- id UUID PRIMARY KEY
- whmcs_client_id BIGINT NOT NULL UNIQUE
- created_at TIMESTAMPTZ NOT NULL
- updated_at TIMESTAMPTZ NOT NULL

The platform does not duplicate customer passwords, billing information,
or payment details.

### 3.2 product_offerings

Stores versioned VPS product definitions.

Columns:

- id UUID PRIMARY KEY
- product_code VARCHAR(100) NOT NULL
- version INTEGER NOT NULL
- name VARCHAR(200) NOT NULL
- vcpu INTEGER NOT NULL
- memory_mb INTEGER NOT NULL
- disk_gb INTEGER NOT NULL
- bandwidth_limit BIGINT
- operating_system_family VARCHAR(50) NOT NULL
- image_policy JSONB NOT NULL
- is_active BOOLEAN NOT NULL
- created_at TIMESTAMPTZ NOT NULL
- updated_at TIMESTAMPTZ NOT NULL

Constraints:

- UNIQUE(product_code, version)
- vcpu > 0
- memory_mb > 0
- disk_gb > 0
- version > 0

A published product version must not be silently modified.
A new version should be created when its resource definition changes.

### 3.3 vps_services

Represents a customer's purchased VPS service.

Columns:

- id UUID PRIMARY KEY
- customer_id UUID NOT NULL REFERENCES customers(id)
- product_offering_id UUID NOT NULL REFERENCES product_offerings(id)
- whmcs_service_id BIGINT NOT NULL UNIQUE
- service_state VARCHAR(30) NOT NULL
- desired_power_state VARCHAR(20) NOT NULL
- hostname VARCHAR(253)
- primary_ip_address INET
- resource_snapshot JSONB NOT NULL
- created_at TIMESTAMPTZ NOT NULL
- updated_at TIMESTAMPTZ NOT NULL
- terminated_at TIMESTAMPTZ

Service state CHECK values:

- pending
- provisioning
- active
- suspending
- suspended
- unsuspending
- terminating
- terminated
- failed
- requires_attention

Desired power state CHECK values:

- on
- off

The resource_snapshot preserves the purchased configuration.
Changes to a product offering must not silently modify existing services.

### 3.4 vm_resource_bindings

Maps a VPS service to its infrastructure resource.

Columns:

- id UUID PRIMARY KEY
- service_id UUID NOT NULL REFERENCES vps_services(id)
- provider_type VARCHAR(50) NOT NULL
- provider_instance_id VARCHAR(255)
- provider_template_id VARCHAR(255)
- cluster_id VARCHAR(255)
- datastore_id VARCHAR(255)
- network_id VARCHAR(255)
- last_observed_state VARCHAR(30) NOT NULL
- last_observed_at TIMESTAMPTZ
- is_current BOOLEAN NOT NULL
- created_at TIMESTAMPTZ NOT NULL
- updated_at TIMESTAMPTZ NOT NULL

Runtime state CHECK values:

- unknown
- powered_on
- powered_off
- suspended
- starting
- stopping
- rebooting
- unavailable
- not_found

Constraints:

- At most one current binding per VPS service.
- Provider instance identifiers must be unique within a provider scope.
- Historical bindings must remain available for audit and migration.

A partial unique index should enforce one current binding per service.

### 3.5 operations

Stores asynchronous VPS operations.

Columns:

- id UUID PRIMARY KEY
- service_id UUID NOT NULL REFERENCES vps_services(id)
- operation_type VARCHAR(40) NOT NULL
- operation_state VARCHAR(30) NOT NULL
- request_payload JSONB NOT NULL
- result_payload JSONB
- requested_by_type VARCHAR(30) NOT NULL
- requested_by_id VARCHAR(255)
- attempt_count INTEGER NOT NULL DEFAULT 0
- max_attempts INTEGER NOT NULL
- lease_owner VARCHAR(255)
- lease_expires_at TIMESTAMPTZ
- heartbeat_at TIMESTAMPTZ
- scheduled_at TIMESTAMPTZ
- started_at TIMESTAMPTZ
- completed_at TIMESTAMPTZ
- error_code VARCHAR(100)
- error_message TEXT
- created_at TIMESTAMPTZ NOT NULL
- updated_at TIMESTAMPTZ NOT NULL

Operation state CHECK values:

- accepted
- queued
- running
- retry_wait
- succeeded
- failed
- cancelled
- requires_attention

Operation type CHECK values:

- create
- power_on
- power_off
- restart
- reset_password
- reinstall
- suspend
- unsuspend
- terminate

Constraints:

- attempt_count >= 0
- max_attempts > 0
- lease fields must be consistent with the running state.
- Completed operations must have a completion timestamp.
- Credentials and private keys must never appear in request_payload,
  result_payload, or error_message.

### 3.6 operation_attempts

Stores individual execution attempts.

Columns:

- id UUID PRIMARY KEY
- operation_id UUID NOT NULL REFERENCES operations(id)
- attempt_number INTEGER NOT NULL
- worker_id VARCHAR(255) NOT NULL
- outcome VARCHAR(30) NOT NULL
- started_at TIMESTAMPTZ NOT NULL
- finished_at TIMESTAMPTZ
- error_code VARCHAR(100)
- sanitized_error_details TEXT

Constraints:

- UNIQUE(operation_id, attempt_number)
- attempt_number > 0

Attempt history must not be overwritten when an operation is retried.

### 3.7 idempotency_records

Prevents duplicate execution of external requests.

Columns:

- id UUID PRIMARY KEY
- scope VARCHAR(100) NOT NULL
- idempotency_key VARCHAR(255) NOT NULL
- request_hash VARCHAR(128) NOT NULL
- operation_id UUID REFERENCES operations(id)
- response_status INTEGER
- created_at TIMESTAMPTZ NOT NULL
- expires_at TIMESTAMPTZ

Constraints:

- UNIQUE(scope, idempotency_key)

The same key with a different request hash must be rejected.
Retention and expiration must be defined before implementation.

### 3.8 outbox_events

Stores events awaiting publication to the message broker.

Columns:

- id UUID PRIMARY KEY
- aggregate_type VARCHAR(100) NOT NULL
- aggregate_id UUID NOT NULL
- event_type VARCHAR(150) NOT NULL
- event_payload JSONB NOT NULL
- publish_attempts INTEGER NOT NULL DEFAULT 0
- created_at TIMESTAMPTZ NOT NULL
- published_at TIMESTAMPTZ
- last_error TEXT

Constraints:

- publish_attempts >= 0

Outbox events must be inserted in the same database transaction
as the state change that requires publication.

### 3.9 audit_events

Stores security-sensitive and administrative actions.

Columns:

- id UUID PRIMARY KEY
- actor_type VARCHAR(30) NOT NULL
- actor_id VARCHAR(255)
- action VARCHAR(150) NOT NULL
- resource_type VARCHAR(100) NOT NULL
- resource_id UUID
- correlation_id UUID
- sanitized_details JSONB NOT NULL
- created_at TIMESTAMPTZ NOT NULL

Audit records must not contain passwords, tokens, private keys,
or other authentication secrets.

## 4. Relationships

- customers 1:N vps_services
- product_offerings 1:N vps_services
- vps_services 1:N vm_resource_bindings
- vps_services 1:N operations
- operations 1:N operation_attempts
- operations 1:0..1 idempotency_records
- operations and service changes 1:N outbox_events
- operations and services 1:N audit_events

The current VM binding is selected using is_current.
Historical bindings remain available.

## 5. Required Indexes

Proposed indexes:

- vps_services(customer_id)
- vps_services(service_state)
- vps_services(whmcs_service_id)
- vm_resource_bindings(service_id)
- vm_resource_bindings(provider_type, provider_instance_id)
- operations(service_id, created_at DESC)
- operations(operation_state, scheduled_at)
- operations(lease_expires_at) for running operations
- operation_attempts(operation_id, attempt_number)
- outbox_events(published_at, created_at)
- audit_events(resource_type, resource_id, created_at DESC)

Unique indexes must also enforce:

- customers.whmcs_client_id
- product_offerings(product_code, version)
- vps_services.whmcs_service_id
- idempotency_records(scope, idempotency_key)
- One current VM binding per service
- Unique provider instance binding within its provider scope

Indexes must be validated against real query patterns before production use.

## 6. Transaction Boundaries

### Creating an operation

A single database transaction should:

1. Validate the service and requested operation.
2. Check or create the idempotency record.
3. Insert the operation.
4. Insert the corresponding outbox event.
5. Commit all changes together.

The API must not publish a queue message before the transaction commits.

### Claiming an operation

A worker must claim an eligible operation atomically.

The implementation should evaluate PostgreSQL row locking,
including SELECT FOR UPDATE SKIP LOCKED where appropriate.

The claim must establish:

- Worker ownership.
- Lease expiration.
- Heartbeat information.
- Attempt history.

### Completing an operation

A successful operation should update:

- Operation state.
- Service state when appropriate.
- VM binding observations when verified.
- Operation attempt outcome.
- Audit events.

Related updates must be committed consistently.

## 7. Concurrency and Recovery

- Only one valid lease may own an operation.
- Expired leases must be detected by a recovery scheduler.
- A lease expiration does not prove the previous worker stopped.
- Infrastructure state must be checked before retrying uncertain operations.
- Conflicting operations on the same service must be serialized.
- Destructive operations require additional validation.
- Queue delivery must be treated as at-least-once.
- Consumers must be idempotent.

## 8. Database Roles

Proposed database roles:

- schema_owner: owns schema and migrations; not used by runtime services.
- api_role: limited access for API operations.
- worker_role: access required to claim and complete operations.
- reconciler_role: read observations and write reconciliation results.
- reporting_role: read-only access to approved operational views.

Runtime services must not connect as schema_owner or PostgreSQL superuser.

## 9. Migration Strategy

The initial schema must be introduced through versioned migrations.

Requirements:

- Migrations must be repeatable in development and staging.
- Every migration must have a reviewable rollback or forward-recovery plan.
- Destructive schema changes require explicit approval.
- Existing SQLite data must not be migrated until mapping and consistency
  rules are documented and tested.
- Production migration must be a separate approved activity.

## 10. Decisions Requiring Review

- PostgreSQL major version and deployment topology.
- UUID generation strategy.
- Product version immutability policy.
- Provider identifier uniqueness scope.
- IP address allocation ownership.
- Whether operation payloads require additional encryption.
- Audit and operation retention periods.
- Outbox cleanup and archival policy.
- Exact worker claim and lease SQL.
- Database backup, restore, and high-availability requirements.

## 11. Status

Design status: Proposed — pending review.

This document is not an executable migration.
No database installation, migration, or production change is authorized.
