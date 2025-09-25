variable "datacenter" {
  description = "vSphere datacenter name"
  type        = string
}

variable "cluster" {
  description = "vSphere cluster name"
  type        = string
}

variable "datastore" {
  description = "vSphere datastore name"
  type        = string
}

variable "network" {
  description = "Network name"
  type        = string
  validation {
    # If static is disabled (false) then 'true' will be passed and will contiue.
    # Otherwise, this vairable needs to not be null and is now required.
    condition     = anytrue([
      for network in keys(local.networks) : contains([var.network], network)
    ])
    error_message = "Network provided is not supported, check the spelling or provide a different network."
  }
}

variable "template" {
  description = "Template name to clone from"
  type        = string
}

variable "vm_name" {
  description = "Virtual machine name"
  type        = string
}

variable "vm_cpus" {
  description = "Number of CPUs"
  type        = number
}

variable "vm_memory" {
  description = "Memory in MB"
  type        = number
}

variable "vm_disk_size" {
  description = "Disk size in GB"
  type        = number
}

variable "firmware" {
  description = "BIOS or EFI"
  type        = string
  default     = "efi"
}

variable "domain_name" {
  # ex. ad.kg-tech.rocks
  description = "Domain name that will be used for the FQDN and search suffixes"
  type        = string
}

variable "use_static_ips" {
  type    = bool
  default = false
}

variable "primary_static_ip" {
  description = "IP addresses and netmask to manually assign"
  type = object({
    ip_address = string
    # 24
    netmask = number
  })
  nullable = true
  default  = null

  validation {
    # If static is disabled (false) then 'true' will be passed and will contiue.
    # Otherwise, this vairable needs to not be null and is now required.
    condition     = var.use_static_ips == true ? var.primary_static_ip != null : true
    error_message = "You must specify IP address and netmask (##)."
  }
}

# variable "default_gateway" {
#   description = "default gateway for the primary NIC"
#   type        = string
#   nullable    = true
#   default     = null

#   validation {
#     condition     = var.use_static_ips == true ? var.default_gateway != null : true
#     error_message = "You must specify the gateway for the primary NIC (only)."
#   }
# }

# variable "dns_servers" {
#   description = "IP addresses to manually assign"
#   type        = list(string)
#   nullable    = true
#   default     = null

#   validation {
#     condition     = var.use_static_ips == true ? var.dns_servers != null : true
#     error_message = "You must specify the gateway for the primary NIC (only)."
#   }
# }

locals {
  networks = {
    VLAN100-Servers-DHCP = {
      default_gateway = null
      dns_servers = [null]
    },
    VLAN110-Servers-Static = {
      default_gateway = "192.168.110.1"
      dns_servers = ["192.168.130.14","192.168.130.15"]
    }
  }
}