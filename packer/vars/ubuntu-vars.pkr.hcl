# ============================================================
# Ubuntu 22.04 build vars — same pattern as debian
# Pass vcenter_password via -var="vcenter_password=$VSPHERE_PASSWORD"
# ============================================================

vcenter_server = "vcenter.rscc.internal"
vcenter_user   = "administrator@vsphere.local"

datacenter = "RSCC-DC01"
cluster    = "RSCC-Cluster01"
datastore  = "ds-ssd-prod-01"
network    = "vlan100-mgmt"
