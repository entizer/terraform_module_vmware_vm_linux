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

  #Primary network interface
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
    #       ipv4_address = var.use_static_ips == false ? null : var.primary_static_ip.ip_address
    #       ipv4_netmask = var.use_static_ips == false ? null : var.primary_static_ip.netmask
    #   }

    #   ipv4_gateway = var.use_static_ips == false ? null : var.default_gateway
    #   dns_server_list = var.use_static_ips == false ? null : var.dns_servers
    #   dns_suffix_list = var.use_static_ips == false ? null : ["ad.kg-tech.rocks"]
    # }
  }

  # VM options
  firmware = var.firmware

  # Enable disk UUID for better disk management
  enable_disk_uuid = true

  # VM tools
  wait_for_guest_net_timeout = 5

  extra_config = {
    "guestinfo.metadata"          = base64encode(templatefile("${path.module}/templates/metadata.tftpl",{
      use_static_ips = var.use_static_ips
      primary_static_ip = var.primary_static_ip
      default_gateway = var.default_gateway
      dns_servers = var.dns_servers
      domain_name = var.domain_name
      vm_name = var.vm_name
    }))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(templatefile("${path.module}/templates/userdata.tftpl",{
      vm_name     = var.vm_name
      domain_name = var.domain_name
    }))
    "guestinfo.userdata.encoding" = "base64"
  }
}