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