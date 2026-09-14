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
|   +-- almalinux/
|   +-- ubuntu/
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

vmware/vsphere version 2.16.1

Lab

The Lab environment contains the reusable VM module used to provision virtual machines from Packer-built golden images.

The VM factory currently supports two operating systems:

AlmaLinux
Ubuntu

The selected OS is controlled through os_type, while the corresponding golden-image UUIDs are supplied through template_uuids.

Example workflow:

cd terraform/environments/lab
terraform init
terraform validate
terraform plan

Actual VM provisioning should only be performed against the authorized lab vSphere environment where the required API write operations are available.

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

Packer Golden Images

Packer is used to build standardized VMware golden images for VPS provisioning.

Current image factories:

packer/almalinux - AlmaLinux golden image
packer/ubuntu - Ubuntu Server golden image using Ubuntu Autoinstall

Both image factories are designed for the same DataHoteling VMware environment and use a dedicated packer SSH account during image creation.

The final image cleanup removes temporary SSH host keys and machine identity data so that cloned VPS instances can receive unique identities.

Actual Packer builds require access to the internal vSphere network and the correct ISO/datastore paths.

Golden Image → VPS Workflow
                 Packer
                   |
        +----------+----------+
        |                     |
        v                     v
   AlmaLinux              Ubuntu
    Template              Template
        |                     |
        +----------+----------+
                   |
                   v
               Terraform
                   |
                   v
             VPS Clone
                   |
                   v
              Ansible
          OS / Service Config

Terraform selects the golden image based on the requested OS:

os_type = "almalinux"
        OR
os_type = "ubuntu"

and maps it to the corresponding template UUID:

template_uuids = {
  almalinux = "<almalinux-template-uuid>"
  ubuntu    = "<ubuntu-template-uuid>"
}
ESXi Licensing

The current DataHoteling ESXi host uses the free VMware ESXi Hypervisor license.

The free license permits normal VM operation through the ESXi Host Client but restricts certain vSphere API write operations.

As a result, Terraform can successfully connect to the production ESXi host and discover infrastructure, but VM creation through the API may be restricted.

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

Builds standardized AlmaLinux and Ubuntu VM images for VPS cloning.

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

Current Status

The project is currently implementing the VPS image factory and multi-OS provisioning foundation.

Completed:

Terraform VMware foundation
Lab environment
Production discovery
Reusable VM module
AlmaLinux Packer golden-image factory
Ubuntu Packer golden-image factory
Terraform support for AlmaLinux and Ubuntu template selection
Sensitive Terraform backup files excluded from Git

Current branch:

feat/vps-image-factory

Recent milestones:

0812bcb  feat: clone VPS VMs from golden image
207e6e4  feat: add Ubuntu golden image factory
99696a7  feat: support Ubuntu and AlmaLinux VPS templates

Pending internal-network validation:

Verify the exact Ubuntu ISO filename in the vSphere datastore
Build and validate the Ubuntu golden image
Verify AlmaLinux and Ubuntu template UUIDs
Run Terraform plan against the lab vSphere environment
Validate VM cloning and guest boot behavior
Complete Ansible post-provisioning
Goals

The long-term goal is to build a reproducible and maintainable infrastructure platform for DataHoteling with:

Infrastructure as Code
Automated VM provisioning
Standardized VM images
Multi-OS VPS provisioning
Configuration management
Hosting automation
Monitoring and observability
CI/CD
Backup and disaster recovery
Infrastructure testing
Failure simulation and recovery procedures
