# Infrastructure as Coded

## Overview

The "Infrastructure as Coded" project automates the provisioning and management of cloud infrastructure using a combination of VMware vCenter, Packer, Terraform, Ansible, and HashiCorp Vault. This approach streamlines the creation and management of virtual machines (VMs) by building reusable OS image templates, deploying VMs, configuring them with necessary software, and securely managing secrets.

## Project Structure

### Directory Layout

```plaintext
.
├── packer/
│   ├── templates/          # Packer templates for creating VM images
│   │   ├── debian12.json   # Packer template for Debian 12
│   │   ├── ubuntu.json     # Packer template for Ubuntu
│   │   └── centos.json     # Packer template for CentOS
│   ├── scripts/            # Scripts and preseed files for initial VM setup
│   │   ├── preseed/        # Preseed files for automated OS installation
│   │   │   ├── debian_preseed.cfg
│   │   │   ├── ubuntu_preseed.cfg
│   │   │   └── centos_preseed.cfg
│   └── vars/               # Variables and configuration files for Packer
│       └── variables.json
├── terraform/
│   ├── main.tf             # Main Terraform configuration file for vCenter
│   ├── variables.tf        # Variables definition for Terraform
│   ├── terraform.tfvars    # Variable values for Terraform
│   ├── outputs.tf          # Outputs from Terraform
│   ├── providers.tf        # Terraform provider configuration
│   └── backend.tf          # Terraform backend configuration
├── ansible/
│   ├── ansible.cfg         # Ansible configuration file
│   ├── inventory/          # Inventory file listing hosts
│   │   └── hosts.ini
│   ├── playbooks/          # Ansible playbooks for server configuration
│   │   ├── apache.yml      # Playbook to install and configure Apache
│   │   ├── users.yml       # Playbook to create users and configure SSH
│   │   ├── common.yml      # Playbook for common tasks (updates, utilities)
│   │   └── db_server.yml   # Playbook to install and configure a database server
│   └── roles/              # Ansible roles for reusable tasks
│       └── common/
│           ├── tasks/
│           │   └── main.yml
│           └── handlers/
│               └── main.yml
├── vault/
│   ├── config/             # Vault configuration files
│   └── secrets/            # Securely stored secrets for Ansible and Terraform
└── README.md               # This file
```
## Requirements

- **VMware vCenter**: Required for managing VM templates and deployments. Ensure you have access to a vCenter instance.
- **Packer**: For creating OS image templates. Download from [Packer.io](https://www.packer.io/downloads).
- **Terraform**: For provisioning VMs and managing infrastructure. Download from [Terraform.io](https://www.terraform.io/downloads).
- **Ansible**: For configuring and managing VMs post-deployment. Follow the installation instructions from [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html).
- **Vault**: For securely storing secrets and sensitive data. Download and install from [HashiCorp Vault](https://www.vaultproject.io/downloads).
- **HTTP Server**: Needed to serve preseed files for automated OS installations.

## Getting Started

### Packer

1. **Install Packer**: Download and install Packer from [Packer.io](https://www.packer.io/downloads).

2. **Configure Packer Templates**: Edit the Packer JSON files in `packer/templates/` to customize the VM images.

3. **Build VM Images**: Run the following commands to build the images:

    ```bash
    packer build packer/templates/debian12.json
    packer build packer/templates/ubuntu.json
    packer build packer/templates/centos.json
    ```

### HTTP Preseed Server

Start an HTTP server to serve the preseed files for automated OS installations:

```bash
cd packer/scripts/preseed/
python3 -m http.server 8080
```
### Terraform

1. **Install Terraform**: Download and install Terraform from [Terraform.io](https://www.terraform.io/downloads).

2. **Configure Terraform Files**: Edit the `terraform/` files and ensure `terraform.tfvars` is updated.

3. **Initialize and Apply Terraform**: Run the following commands:

    ```bash
    cd terraform/
    terraform init
    terraform apply
    ```

### Ansible

1. **Install Ansible**: Follow the installation instructions from [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html).

2. **Configure Inventory**: Update `ansible/inventory/hosts.ini` with VM IP addresses.

3. **Run Playbooks**: Run the Ansible playbooks to configure the VMs:

    ```bash
    ansible-playbook ansible/playbooks/apache.yml
    ansible-playbook ansible/playbooks/users.yml
    ansible-playbook ansible/playbooks/common.yml
    ansible-playbook ansible/playbooks/db_server.yml
    ```


### Vault Integration

Vault is used to securely store and retrieve sensitive information such as passwords, API keys, and SSH credentials. The secrets are dynamically injected into the Terraform and Ansible configurations during deployment.

1. **Install Vault**: Download and install Vault from [HashiCorp Vault](https://www.vaultproject.io/downloads).

2. **Configure Vault**: Set up Vault to store the secrets required by the project. The secrets are stored in `vault/secrets/`.

3. **Use Vault in Terraform and Ansible**: Modify your Terraform and Ansible configurations to pull secrets from Vault instead of hardcoding them directly.

   For example:
   - In Terraform, you can use `vault_generic_secret` to retrieve secrets.
   - In Ansible, you can use the `ansible-vault` integration to securely access secrets.
