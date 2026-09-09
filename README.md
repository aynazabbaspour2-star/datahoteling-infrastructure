# DataHoteling Infrastructure

Infrastructure as Code and DevOps automation project for the DataHoteling hosting infrastructure.

The project is designed around a layered automation architecture using Terraform, Packer, Ansible, monitoring, and GitHub Actions.

## Architecture

```text
                         Internet
                            |
                            v
                     Router / Firewall
                            |
                            v
                       VMware ESXi
                            |
                            v
                    AlmaLinux Server
                            |
          +-----------------+-----------------+
          |                 |                 |
          v                 v                 v
       cPanel             WHMCS          PowerDNS
          |                 |                 |
          v                 v                 v
      Apache/Web       Customer Portal      DNS
          |
          +-- Exim
          +-- Dovecot
          +-- Hosting Accounts
Automation Architecture
                         GitHub
                            |
                            v
                     GitHub Actions
                            |
             +--------------+--------------+
             |              |              |
             v              v              v
         Terraform        Packer        Ansible
             |              |              |
             v              v              v
          VMware ESXi    VM Images     Configuration
             |
             v
        Virtual Machines
Repository Structure
datahoteling-infrastructure/
|
+-- architecture/
|
+-- ansible/
|   +-- inventories/
|   +-- playbooks/
|   +-- roles/
|
+-- monitoring/
|
+-- packer/
|
+-- scripts/
|
+-- terraform/
|   +-- environments/
|   |   +-- lab/
|   |   +-- production/
|   |
|   +-- modules/
|   |   +-- network/
|   |   +-- storage/
|   |   +-- vm/
|   |
|   +-- setup-vsphere-provider.sh
|   +-- terraform.tfvars.example
|
+-- .github/
    +-- workflows/
Terraform

Terraform is responsible for infrastructure provisioning and lifecycle management on VMware ESXi.

The project separates environments:

lab - safe environment for testing infrastructure changes
production - production infrastructure discovery and management

The VMware provider used by this project is:

vmware/vsphere

Provider version:

2.16.1
Lab

The Lab environment contains the reusable VM module used to provision virtual machines.

Example workflow:

cd terraform/environments/lab

terraform init
terraform validate
terraform plan

Actual VM provisioning should only be performed against an ESXi host where the required API write operations are available.

Production

The Production environment currently uses Terraform for infrastructure discovery.

It discovers:

vSphere datacenter
ESXi host
datastore
VM network
resource pool

Example:

cd terraform/environments/production

terraform init
terraform validate
terraform plan

The current production configuration is discovery-only and does not create or modify production virtual machines.

ESXi Licensing

The current DataHoteling ESXi host uses the free VMware ESXi Hypervisor license.

The free license permits normal VM operation through the ESXi Host Client but restricts certain vSphere API write operations.

As a result, Terraform can successfully connect to the production ESXi host and discover infrastructure, but VM creation through the API is currently restricted.

The architecture therefore separates production discovery from lab provisioning:

Production
    |
    +-- Terraform Discovery / Read-only

Lab
    |
    +-- Terraform Provisioning
            |
            +-- Packer
            +-- Ansible
            +-- Monitoring
            +-- CI/CD

This prevents experimental infrastructure changes from being performed directly against production.

Infrastructure Components
VMware / ESXi

Provides the virtualization layer for the DataHoteling infrastructure.

Terraform

Manages infrastructure as code and provides a reproducible infrastructure definition.

Packer

Will be used to build standardized VM images.

Ansible

Will be used for operating system and service configuration after VM provisioning.

cPanel / WHM

Provides hosting management and server administration.

WHMCS

Provides customer management, billing, ordering, and hosting automation.

Target workflow:

Customer
   |
   v
WHMCS
   |
   +-- Domain
   +-- Order
   +-- Payment
   +-- Hosting Service
          |
          v
       cPanel / WHM
          |
          v
     Hosting Account
PowerDNS

Provides authoritative DNS management for hosted domains.

Monitoring

The monitoring layer will use:

Prometheus
Grafana
Loki
Alertmanager

The goal is to provide visibility into infrastructure health, services, logs, and operational events.

Security

Secrets are intentionally excluded from Git.

Sensitive files such as:

*.tfvars
*.tfstate
*.tfplan
.env
*.key
*.pem

are ignored through .gitignore.

Credentials should be provided through environment variables, secret management, or CI/CD secrets rather than committed to the repository.

Development Workflow

Infrastructure changes follow this general workflow:

Developer
    |
    v
Git
    |
    v
Terraform Validate
    |
    v
Terraform Plan
    |
    v
Lab Testing
    |
    v
Review
    |
    v
Production

Production changes should not be applied directly without validation in a suitable Lab environment.

Goals

The long-term goal is to build a reproducible and maintainable infrastructure platform for DataHoteling with:

Infrastructure as Code
Automated VM provisioning
Standardized VM images
Configuration management
Hosting automation
Monitoring and observability
CI/CD
Backup and disaster recovery
Infrastructure testing
Failure simulation and recovery procedures
Status

Work in progress.

Current milestone:

Terraform VMware foundation
        |
        +-- Lab environment
        +-- Production discovery
        +-- Reusable VM module

Next milestones:

Packer
  |
  v
Ansible
  |
  v
Monitoring
  |
  v
GitHub Actions
  |
  v
Backup / Disaster Recovery
