#parameters that coustermer needs to enter

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowerccase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string
  default     = ""

  validation {
    error_message = "Prefix must begin with a lowercase letter and contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 16
  }
}


variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
  default     = ""
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
  default     = ""
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created."
  type        = string
  default     = ""
}

variable "windows_ssh_publickey" {
  type        = string
  default     = ""
  description = "windows_ssh_publickey"
}

variable "vtl_public_key" {
  type        = string
  default     = ""
  description = "VTL public key for SSH key creation"
}

variable "IBMI_ssh_publickey" {
  type        = string
  default     = ""
  description = "IBMI_ssh_publickey"
}

variable "AIX_ssh_publickey" {
  type        = string
  default     = ""
  description = "AIX_ssh_publickey"
}

variable "linux_ssh_publickey" {
  type        = string
  default     = ""
  description = "linux_ssh_publickey"
}

variable "vtl_index_volume_size" {
  type        = number
  default     = 20
  description = "block-storage-volume maximum size of the volume in 2000GB, it will fail if we exceed the size"
}

variable "vtl_tape_volume_size" {
  type        = number
  default     = 20
  description = "tape-storage-volume maximum size of the volume in 2000GB, it will fail if we exceed the size"
}

variable "vtl_configuration_volume_size" {
  type        = number
  default     =20
  description = "configuration-storage-volume maximum size of the volume in 2000GB, it will fail if we exceed the size"
}

#optional variables- /Defaul variables

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
  default     = "Default"

}

variable "powervs_management_network" {
  description = "Name of the IBM Cloud PowerVS management subnet and CIDR to create."
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "mgmt_net"
    cidr = "10.51.0.0/24"
  }
}


variable "powervs_backup_network" {
  description = "Name of the IBM Cloud PowerVS backup network and CIDR to create."
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "bkp_net"
    cidr = "10.52.0.0/24"
  }
}

variable "cloud_connection" {
  description = "Cloud connection configuration: speed (50, 100, 200, 500, 1000, 2000, 5000, 10000 Mb/s), count (1 or 2 connections), global_routing (true or false), metered (true or false)"
  type = object({
    speed          = number
    global_routing = bool
    metered        = bool
  })

  default = {
    speed          = 5000
    global_routing = true
    metered        = true
  }
}

variable "vtl_memory" {
  type        = number
  default     = 18
  description = " VTL memory amount in GB; it should be >= 16 + (2 * licensed_repository_capacity)"
}

variable "vtl_processors" {
  type        = number
  default     = 2
  description = "Number of CPU cores to allocate for VTL instance"
}

variable "vtl_processor_type" {
  type        = string
  default     = "shared"
  description = "VTL processor type: 'shared', 'capped', or 'dedicated'"
}

variable "vtl_sys_type" {
  type        = string
  default     = "s922"
  description = "Type of system on which to create the VTL instance: 's922', 'e880', 'e980', 'e1080', or 's1022'"
}

variable "vtl_storage_type" {
  type        = string
  default     = "tier3"
  description = "Type of storage tier to assign to the VTL instance based on required performance: 'tier1' or 'tier3'"
}

variable "vtl_licensed_repository_capacity" {
  type        = number
  default     = 1
  description = "VTL licensed repository capacity in TB"
}

variable "vtl_public_network_name" {
  type        = string
  default     = ""
  description = "First network ID or name to assign to the VTL instance"
}

variable "vtl_public_cidr" {
  type        = string
  default     = ""
  description = "First network IP addresse range"
}

variable "vtl_public_gateway" {
  type        = string
  default     = ""
  description = "First network gateway IP address"
}


variable "vtl_placement_group" {
  type        = string
  default     = ""
  description = "Server group name where the VTL instance will be placed, as defined for the selected Power Systems Virtual Server CRN"
}
variable "vtl_affinity_policy" {
  type        = string
  default     =  "anti-affinity"
  description = "Storage anti-affinity policy to use for placemant of the VTL volume if PVM instance IDs are sepcified"
}


variable "powervs_image_names" {
  description = "List of Images to be imported into cloud account from catalog images."
  type        = list(string)
  default = [ "RHEL8-SP6","7200-05-05","IBMi-72-09-2924-8" ]
}

variable "IBMI_memory" {
  type        = number
  default     = "2"
  description = "IBMI_memory"
}

variable "IBMI_processors" {
  type        = number
  default     = "0.25"
  description = "IBMI_processors"
}



variable "IBMI_proc_type" {
  type        = string
  default     = "shared"
  description = "IBMI_proc_type"
}

variable "IBMI_sys_type" {
  type        = string
  default     = "s922"
  description = "IBMI_sys_type"
}

variable "IBMI_storage_type" {
  type        = string
  default     = "tier3"
  description = "Type of storage tier to assign to the VTL instance based on required performance: 'tier1' or 'tier3'"
}








variable "AIX_memory" {
  type        = number
  default     = "2"
  description = "AIX_memory"
}

variable "AIX_processors" {
  type        = number
  default     = "0.25"
  description = "AIX_processors"
}



variable "AIX_proc_type" {
  type        = string
  default     = "shared"
  description = "AIX_proc_type"
}

variable "AIX_sys_type" {
  type        = string
  default     = "s922"
  description = "AIX_sys_type"
}

variable "AIX_storage_type" {
  type        = string
  default     = "tier3"
  description = "Type of storage tier to assign to the VTL instance based on required performance: 'tier1' or 'tier3'"
}





variable "linux_memory" {
  type        = number
  default     = "2"
  description = "linux_memory"
}

variable "linux_processors" {
  type        = number
  default     = "0.25"
  description = "linux_processors"
}


variable "linux_proc_type" {
  type        = string
  default     = "shared"
  description = "linux_proc_type"
}

variable "linux_sys_type" {
  type        = string
  default     = "s922"
  description = "linux_sys_type"
}

variable "linux_storage_type" {
  type        = string
  default     = "tier3"
  description = "Type of storage tier to assign to the VTL instance based on required performance: 'tier1' or 'tier3'"
}





