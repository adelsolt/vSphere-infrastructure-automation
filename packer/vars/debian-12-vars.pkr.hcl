# ============================================================
# Debian 12 build vars
#
# Pass the password at build time — never store it in this file.
# The variable is declared without a default in the template,
# so Packer will refuse to build if you forget to pass it:
#
#   packer build \
#     -var-file=vars/debian-12-vars.pkr.hcl \
#     -var="vcenter_password=$VSPHERE_PASSWORD" \
#     templates/debian.pkr.hcl
# ============================================================

vcenter_server = "vcenter.rscc.internal"
vcenter_user   = "administrator@vsphere.local"
# vcenter_password — intentionally omitted, pass via -var at CLI

datacenter = "RSCC-DC01"
cluster    = "RSCC-Cluster01"
datastore  = "ds-ssd-prod-01"
network    = "vlan100-mgmt"
