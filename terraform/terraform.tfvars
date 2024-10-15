vsphere_user     = "administrator@vsphere.local"
vsphere_password = "your_password"
vsphere_server   = "your_vcenter_ip"

datacenter       = "Datacenter1"
datastore        = "datastore1"
cluster          = "Cluster1"
network          = "VM Network"

vm_template      = "debian12-template"  # Change to ubuntu-template or centos-template for different OS
vm_name          = "test-vm"
num_cpus         = 2
memory           = 4096
disk_size        = 10

vm_ip            = "192.168.1.100"  # Adjust to match your static IP setup
vm_gateway       = "192.168.1.1"    # Adjust to match your gateway
