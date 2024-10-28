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
## Project Components

- **VMware vCenter**: Required for managing VM templates and deployments. 
- **Packer**: For creating OS image templates. 
- **Terraform**: For provisioning VMs and managing infrastructure.
- **Ansible**: For configuring and managing VMs post-deployment.
- **Vault**: For securely storing secrets and sensitive data.
- **HTTP Server**: Needed to serve preseed files for automated OS installations.

## Getting Started

### Packer

1. **Installed Packer**: Downloaded and installed Packer 

2. **Configured Packer Templates**: Edited the Packer JSON files in `packer/templates/` to customize the VM images.

3. **VM Images Building**

    ```bash
    packer build packer/templates/debian12.json
    packer build packer/templates/ubuntu.json
    packer build packer/templates/centos.json
    ```

### HTTP Preseed Server

Starting an HTTP server to serve the preseed files for automated OS installations:

```bash
cd packer/scripts/preseed/
python3 -m http.server 8080
```
### Terraform

1. **Installed Terraform**

2. **Configured Terraform Files**: located in `terraform/` 

3. **Initialized and Applied Terraform**

    ```bash
    cd terraform/
    terraform init
    terraform apply
    ```

### Ansible

1. **Installed Ansibled**

2. **Configured Inventory**: Update `ansible/inventory/hosts.ini` with VM IP addresses.

3. **Running Playbooks**

    ```bash
    ansible-playbook ansible/playbooks/apache.yml
    ansible-playbook ansible/playbooks/users.yml
    ansible-playbook ansible/playbooks/common.yml
    ansible-playbook ansible/playbooks/db_server.yml
    ```


### Vault Integration

Vault is used to securely store and retrieve sensitive information such as passwords, API keys, and SSH credentials. Which will be dynamically injected into the Terraform and Ansible configurations during deployment.

1. **Installed Vault**

2. **Configured Vault**: Setted up Vault to store the secrets required by the project. The secrets are stored in `vault/secrets/`.

3. **Used Vault in Terraform and Ansible**: The Terraform and Ansible configurations are modified to pull secrets from Vault instead of hardcoding them directly.

   For example:
   - In Terraform, `vault_generic_secret` can used to retrieve secrets.
   - In Ansible, `ansible-vault` can used integration to securely access secrets.
