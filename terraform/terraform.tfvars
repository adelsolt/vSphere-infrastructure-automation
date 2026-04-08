vsphere_server = "vcenter.rscc.internal"
vault_address  = "https://vault.rscc.com:8200"

datacenter_name = "RSCC-DC01"
cluster_name    = "RSCC-Cluster01"
datastore_name  = "ds-ssd-prod-01"
network_name    = "vlan100-mgmt"

vm_name              = "postgre-server"
vm_num_cpus          = 2
vm_memory            = 4096
disk_size            = 20
vm_guest_id          = "debian11_64Guest"
network_adapter_type = "vmxnet3"
domain               = "rscc.internal"

template_uuid = "420f4e0b-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
