# Data sources
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Virtual Machine Resource
resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = "terraform-managed"

  num_cpus = var.vm_cpus
  memory   = var.vm_memory

  guest_id = data.vsphere_virtual_machine.template.guest_id

  # Network interface with VMXNET3
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  # Disk configuration - 20GB
  disk {
    label            = "disk0"
    size             = var.vm_disk_size
    thin_provisioned = true
    unit_number      = 0
  }

  # Clone from template
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    # customize {
    #   linux_options {
    #     host_name = var.vm_name
    #     domain    = "ad.kg-tech.rocks"
    #   }

    #   network_interface {
    #   #     ipv4_address = "192.168.1.100"  # Change to your desired IP
    #   #     ipv4_netmask = 24
    #   }

    #   #   ipv4_gateway = "192.168.1.1"  # Change to your gateway
    #   #   dns_server_list = ["8.8.8.8", "8.8.4.4"]
    # }
  }

  # VM options
  firmware = var.firmware

  # Enable disk UUID for better disk management
  enable_disk_uuid = true

  # VM tools
  wait_for_guest_net_timeout = 5
}