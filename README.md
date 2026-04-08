# Automated resource provisioning in Vsphere vCenter with Packer, Terraform, Ansible and Vault

Automated VM provisioning pipeline for a VMware vSphere environment. The whole thing, from raw ISO to a configured, hardened server, runs without touching vCenter manually. Built with Packer, Terraform, Ansible, and HashiCorp Vault.

## What this does

You give it an ISO. It gives you a production-ready server.

Packer takes the ISO and bakes it into a reusable vCenter template. Terraform clones that template into a real VM with whatever CPU/RAM/disk/network spec you define. Ansible SSHes in and finishes the job, packages, users, services, SSH hardening. Vault sits behind all three stages handling credentials so nothing sensitive ever touches a file or an env var you didn't explicitly set.

The split between the three tools is intentional. Packer runs once per OS version, maybe a few times a year when you want to refresh the base image. Terraform and Ansible run every time you need a new VM, which is where the real time savings are. From `terraform apply` to a fully configured machine is usually under 5 minutes.

```
ISO in vCenter datastore
        │
      Packer  ──── preseed/kickstart answers the installer
        │           post-install script cleans up, resets machine-id
        ▼
  VM Template in vCenter
        │
    Terraform  ──── pulls vSphere creds from Vault
        │           clones template, sets hostname via guest customization
        │           waits for VMware Tools to report an IP
        ▼
  Running VM (IP from terraform output)
        │
     Ansible  ──── reads IP from hosts.ini
        │          fetches runtime secrets from Vault
        │          hardens SSH, installs packages, creates users, starts services
        ▼
  web-01.rscc.internal, ready
```

## Requirements

You need these installed locally before anything runs:

| Tool | Min version |
|------|------------|
| Packer | 1.9.0 |
| Terraform | 1.6.0 |
| Ansible | 2.14 |
| Vault CLI | 1.15 |

On macOS: `brew install packer terraform vault` and `pip install ansible`.
On Linux: grab the binaries from releases.hashicorp.com or use your package manager.

On the vSphere side you need vCenter 7.0 or newer, a datastore with the ISO files already uploaded, and an account with permissions to create and manage VMs. The expected ISO paths are in the `locals` block of each Packer template, update those to match where you actually put the files.

## Files you need to fill in before running anything

**`packer/vars/debian-12-vars.pkr.hcl`** (and the ubuntu/centos equivalents), set `vcenter_server`, `vcenter_user`, `datacenter`, `cluster`, `datastore`, and `network` to match your vCenter environment. The password is not in this file on purpose, pass it at build time via `-var="vcenter_password=$VSPHERE_PASSWORD"`.

**`terraform/terraform.tfvars`**, fill in `vsphere_server`, `vault_address`, your vSphere topology names (datacenter, cluster, datastore, network), and the VM spec. The `template_uuid` field at the bottom gets filled in after you run Packer, it comes from `packer/builds/debian12-manifest.json`.

**`ansible/inventory/hosts.ini`**, update the IP addresses after `terraform apply`. The easiest way is `terraform output vm_default_ip`, then paste that into the right group.

**`ansible/group_vars/vault.yml`**, this is an ansible-vault encrypted file. You create it with `ansible-vault create group_vars/vault.yml` and put in `vault_token` and `vault_mysql_root_password`. The vault password file lives at `~/.ansible_vault_pass.txt` (configured in `ansible.cfg`).

## Running it

### Step 0, start Vault and store your secrets

This runs once, on whatever machine will host your Vault instance. If you already have a running Vault, skip straight to the `kv put` commands.

```bash
vault server -config=vault/config/vault-config.hcl &

vault operator init    # save the unseal keys and root token, you need these to restart Vault
vault operator unseal  # run this 3 times with 3 different keys from the init output
vault login            # use the root token
```

Now push the credentials that Terraform and Ansible will pull at runtime:

```bash
vault kv put secret/vsphere \
  user="administrator@vsphere.local" \
  password="your-vcenter-password"

vault kv put secret/ansible \
  user="packer" \
  private_key="$(cat ~/.ssh/rscc_id_rsa)"

vault kv put secret/mysql \
  root_password="your-mysql-root-password"
```

### Step 1, build OS templates with Packer

Run this from the `packer/` directory. The `-var` flag for the password reads from your shell environment so it never hits disk.

```bash
cd packer/
packer init templates/debian.pkr.hcl

packer build \
  -var-file=vars/debian-12-vars.pkr.hcl \
  -var="vcenter_password=$VSPHERE_PASSWORD" \
  templates/debian.pkr.hcl
```

Same pattern for Ubuntu and CentOS:

```bash
packer build -var-file=vars/ubuntu-vars.pkr.hcl -var="vcenter_password=$VSPHERE_PASSWORD" templates/ubuntu.pkr.hcl
packer build -var-file=vars/centos-vars.pkr.hcl -var="vcenter_password=$VSPHERE_PASSWORD" templates/centos.pkr.hcl
```

When the build finishes, grab the template UUID from `builds/debian12-manifest.json` and drop it into `terraform/terraform.tfvars` as `template_uuid`. You only need to redo this step when you want a fresh base image, not every time you deploy a VM.

### Step 2, provision the VM with Terraform

```bash
cd terraform/
export VAULT_TOKEN="hvs.your-token-here"

terraform init
terraform plan   # read this before applying, it tells you exactly what gets created
terraform apply
```

After apply completes:

```bash
terraform output vm_default_ip   # copy this into ansible/inventory/hosts.ini
```

### Step 3, configure the VM with Ansible

Update `hosts.ini` with the IP from the previous step, then run the playbooks in order. Common always goes first.

```bash
cd ansible/

ansible-playbook playbooks/common.yml          # baseline, packages, SSH hardening, hostname
ansible-playbook playbooks/users.yml           # service accounts, SSH keys, removes packer user
ansible-playbook playbooks/apache-pb.yml       # web servers only (webservers group)
ansible-playbook playbooks/mysql-pb.yml        # db servers only (dbservers group)
```

If you want to run against a specific host instead of the whole group:

```bash
ansible-playbook playbooks/common.yml --limit web-01
```

## Secrets, how it actually works

Nothing sensitive is hardcoded anywhere in this repo. Credentials flow through three mechanisms depending on the tool:

Packer gets the vCenter password from the `-var` flag you pass at CLI, which you source from a shell env var. It never writes it to disk and it never appears in the build output because the variable is marked `sensitive = true`.

Terraform fetches the vSphere credentials from HashiCorp Vault using the `vault_generic_secret` data source in `providers.tf`. The only thing Terraform needs from you is a `VAULT_TOKEN` env var, everything else it pulls from Vault at plan time.

Ansible uses two layers. The `group_vars/vault.yml` file is encrypted at rest with ansible-vault, and contains the Vault token and MySQL password. When a playbook runs, Ansible decrypts that file using your `~/.ansible_vault_pass.txt`. The common playbook then uses the Vault token to make an API call to HashiCorp Vault and pull any additional runtime secrets.

The `vault/secrets/credentials.json` file in this repo is just a reference, it shows you the key structure so you know what to `kv put` into Vault. The real values only ever exist inside the running Vault instance.

## Troubleshooting

**Packer times out waiting for SSH**, the installer couldn't reach the preseed/kickstart file. Packer serves it over a temporary HTTP server on a random port (usually 8000–9000). Check that your firewall isn't blocking outbound connections from the VM to your workstation on those ports. The boot command logs in the Packer output will show you the URL it tried to use.

**Terraform fails with "resource pool not found"**, the names in `terraform.tfvars` have to match vCenter exactly, including capitalization. `Cluster1` and `cluster1` are different things to vCenter. Double-check in vCenter under Hosts and Clusters.

**Ansible can't reach the VM**, if it's a fresh deploy, the host key won't be in known_hosts yet, but `host_key_checking = False` in `ansible.cfg` handles that. More likely the IP in `hosts.ini` is wrong or the `packer` user doesn't have SSH key auth set up. Verify with `ssh -i ~/.ssh/rscc_id_rsa packer@<vm-ip>` before running the playbook.

**Multiple VMs getting the same DHCP lease**, the template was built without the machine-id reset. Fix it per-VM with:
```bash
sudo truncate -s 0 /etc/machine-id && sudo systemd-machine-id-setup
```
Then rebuild the template so future clones don't have this issue.
