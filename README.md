# DataHoteling Infrastructure

Infrastructure as Code and DevOps automation for the DataHoteling hosting platform.

## Goals

- VMware/ESXi infrastructure automation
- Terraform-based infrastructure provisioning
- Ansible configuration management
- Packer-based image management
- cPanel/WHM infrastructure automation
- PowerDNS management
- Monitoring and observability
- CI/CD with GitHub Actions
- Backup and disaster recovery
- Secure and reproducible infrastructure

## Architecture

```text
Internet
   |
Router / Firewall
   |
ESXi
   |
AlmaLinux
   |
cPanel / WHM
   |
+--------------------------------+
| WHMCS | PowerDNS | Mail        |
| Apache | Hosting Accounts      |
+--------------------------------+

Automation:

GitHub
   |
GitHub Actions
   |
Terraform / Ansible / Packer
   |
VMware ESXi
Repository Structure
architecture/   Infrastructure documentation
terraform/      Infrastructure as Code
ansible/        Configuration management
packer/         Image building
monitoring/     Observability
scripts/        Operational scripts
.github/        CI/CD workflows
Infrastructure

The production infrastructure is based on VMware ESXi and an AlmaLinux
virtual machine running the DataHoteling hosting platform.

Core services include:

cPanel / WHM
WHMCS
Apache
PowerDNS
Exim
Dovecot
Automation Strategy

The infrastructure will be managed using a layered approach:

Terraform — infrastructure provisioning
Packer — image building
Ansible — configuration management
GitHub Actions — CI/CD and automation
Prometheus / Grafana — monitoring

Production changes will be validated in a lab environment before being
applied to the production infrastructure.

Status

🚧 Work in progress
