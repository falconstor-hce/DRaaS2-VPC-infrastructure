variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowerccase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string
  default     = "falcon-draas"

  validation {
    error_message = "Prefix must begin with a lowercase letter and contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 16
  }
}


variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
  default     = "5Frgf9C72JYeD0NlnP2Flo1qJu8v3BvQ2WdeaGDyzI1v"
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
  default     = "jp-tok"
}

variable "zone" {
  description = "zone where VPC will be created. ex:jp-tok-1,us-south-1"
  type        = string
  default     = "jp-tok-1"
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created."
  type        = string
  default     = "tok04"
}

variable "windows_ssh_publickey" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChrNQNwwYis566zWenxharz+8U4Ipgh/8JCmuSnOShVZlRniXAAdARmamHX/cxn/0N3/85G88Ls5plrzBRVUHya9x07qQZLoeFQC1j1hShrRemo+PGGG1bEZzF3qYzTD3d75aEYQfwr4qk4H+T5kayb2zaHGzmLdGoFPzbeLN//qeYrchbJ+NvjCW8V41wUzc9a86fzabl+RupfKBvGx9gMib8gMl4Tb+2uZcSbXwswYKRztdCKfvTXG2wAuwnPIPXXBUy4FR6yQvlpyWvncJy8+0WRbKdU0oNDu0rYsMw6MaJD5KbjAfn+f4Y681eC+yyuTaTKvBud6YPGCdFLEOF rsa-key-20230517"
  description = "windows_ssh_publickey"
}

variable "vtl_public_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUTx8/7VhW7yk5o0vGccLJmo4yJ9z2swwG/tj0kdBDsX4TYcMFhV6SBkn1O6yiayM8ycZZQ1eIohtq36Fv1NMlNZ8oyQB9rUzIBzN2iH54cr4Ig/mhqqx1cULuZbwddZSUohgkmHXM9yvORL7SmtSA9a/onGSztB1iIYCaoyvC8FYWYio/uqTnaSuR15sKXwmkcCaGYy5m2P2xnIERrUTjHxlCPLXBborO0vP8BOzc60HswAzL6WBDR7Gzt48gprX78DlX3otufkpksVmHuD2G9C5vbAcbQ840s8FqJNsu/RTcv2yd4Lo7/fpBIEjik6RgftgE2mvRt/IH6T4s4izv rsa-key-20230517"
  description = "VTL public key for SSH key creation"
}

variable "IBMI_ssh_publickey" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCEOtgEaP7wcK+yZUGv6hXCRntUicg3KVpnkLtNMIACljC4Ib4HoLvRqk18LVplSiYiGfAN0QJpEbj7HJ/rUcaxmngbwaMrD+7+X5B8zn/80dVs8oery15lAG8vxaUugUPqqfylFrMLJsXvLaUvmfaISX9f5PsAZN+2S3WeyhpzZVKf0uV1jiY2czAuGdE/qYbOAKyE2JVd+h+1F/tHZ22aYJvc8pdk2JhESZ4lE0nbqG/eXcblkTcLcpbITVgtPAhR+GafmkKL8nsFdLkj6G8eHqgot9GjPgGs7UWvt4HPFJiveRFASv/HmPYO4305OeiQgIQwbtiiWMXvcvBBHSH5 rsa-key-20230517"
  description = "IBMI_ssh_publickey"
}

variable "AIX_ssh_publickey" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCNyn5zE3zq2xHy40XbFRyyTxGmt7UOL0pBYBE+SDGFfDOVei0ZBu1nKmGIGQ1uQB5f1lxaQDX6a9rpIzMlbn23Igdua8Y5UXKwIRgUiGgAetRmDZTPXWjGc5KhX3GaftpMrBbooaDSR+APsIREG8oBeKoiX2FKvILdyoRAYoeFQv8tYHxWJ3dW1F/llsROcxMQxL1mqULc0iHzOYrrbl2grDjo10UP9tVcPd9MJE7JkykeXt8MbgTn8WaXRSfO4sD8ND5VZwO2oXV7eYk5bcfUENayZrFbtijIk5ubZOuQbec75+W3klJQ3xnwWxsoVV2asTtugpileVeBKjSFLXdR rsa-key-20230517"
  description = "AIX_ssh_publickey"
}

variable "linux_ssh_publickey" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/9KxG3ShhWAQ9WgxvqpER83JireG3VuN/ODdrbESf+4F3QdqXJ0LGRmMoaAY5on0Vad9C0iNMR2vrec/pztzg2PGlpVPK9TCYBfo4gn0447OUlV4zl+BGBjn1O63sQ2Dynsm+GSqFcDxFNodbNnG4XnrEa//0701EFbZDufMoYtNAGecnbgW78V3fHWZ6i0ZaMwN/6JW9tN1qGgIdCiMCpS7MPCA6lulpTg9dqhSaJecswT80htbfZPP60n/yLsuHZabruGE0oAA4VtCf/jQh9kjsSKz5eT22pVMfzpAYiZRM74FhD72CSvDW+7PcM8icVcTx/DpC2F+tqbPKOFgd rsa-key-20230517"
  description = "linux_ssh_publickey"
}



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


variable "powervs_image_names" {
  description = "List of Images to be imported into cloud account from catalog images."
  type        = list(string)
  default     = ["RHEL8-SP6","7200-05-05","IBMi-72-09-2924-8"]
}


variable "powervs_os_image_name1" {
  description = "Image Name for PowerVS Instance"
  type        = string
  default     = "RHEL8-SP6"
}
variable "powervs_os_image_name2" {
  description = "Image Name for PowerVS Instance"
  type        = string
  default     = "7200-05-05"
}
variable "powervs_os_image_name3" {
  description = "Image Name for PowerVS Instance"
  type        = string
  default     = "IBMi-72-09-2924-8"
}

variable "IBMI_memory" {
  type        = number
  default     = 18
  description = "IBMI_memory"
}

variable "IBMI_processors" {
  type        = number
  default     = 2
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
  default     = 18
  description = "AIX_memory"
}

variable "AIX_processors" {
  type        = number
  default     = 2
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
  default     = 18
  description = "linux_memory"
}

variable "linux_processors" {
  type        = number
  default     = 2
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





