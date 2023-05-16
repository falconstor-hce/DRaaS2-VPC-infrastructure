#COS and bucket creation
resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.prefix}-cos-instance"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}
data "ibm_resource_instance" "instance" {
  name              = ibm_resource_instance.cos_instance.name
  
}
resource "ibm_resource_key" "key" {
  name                 = "${var.prefix}-key"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  parameters           = { "HMAC" = true }
  role                 = "Manager"

  //User can increase timeouts
  timeouts {
    create = "15m"
    delete = "15m"
  }
}

resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name           = "${var.prefix}-bucket"
  resource_instance_id  = data.ibm_resource_instance.instance.id
  region_location       = var.region
  storage_class         = "standard"
  endpoint_type         = "public" 
}

data "ibm_cos_bucket" "standard" {
  bucket_name          = ibm_cos_bucket.cos_bucket.bucket_name
  resource_instance_id = data.ibm_resource_instance.instance.id
  bucket_region = ibm_cos_bucket.cos_bucket.region_location
  bucket_type = "region_location"
  
}


#VPC creation

resource "ibm_is_vpc" "example" {
  name = "${var.prefix}-vpc"
}

data "ibm_is_vpc" "vpc" {
  name = ibm_is_vpc.example.name
}

#virtual_endpoint_gateway creation

resource "ibm_is_virtual_endpoint_gateway" "example4" {
  name = "${var.prefix}-vpe"
  target {
    crn           = "crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.${var.region}.cloud-object-storage.appdomain.cloud"
    resource_type = "provider_cloud_service"
  }
  vpc            = data.ibm_is_vpc.vpc.id
}

data "ibm_is_image" "example" {
  name = "ibm-windows-server-2022-full-standard-amd64-7"
}

resource "ibm_is_vpc_address_prefix" "example" {
  cidr = "10.0.1.0/24"
  name = "add-prefix"
  vpc  = ibm_is_vpc.example.id
  zone = "jp-tok-1"
}

resource "ibm_is_subnet" "example" {
  depends_on = [
    ibm_is_vpc_address_prefix.example
  ]
  name            = "windows-subnet"
  vpc             = ibm_is_vpc.example.id
  zone            = "jp-tok-1"
  ipv4_cidr_block = "10.0.1.0/24"
}

#Windows server creation in VPC infrastrucrure

resource "ibm_is_ssh_key" "example" {
  name       = "windows-ssh"
  public_key = var.windows_ssh_publickey
}

resource "ibm_is_instance" "example" {
  name    = "${var.prefix}-windows-instance"
  image   = data.ibm_is_image.example.id
  profile = "bx2-2x8"
  metadata_service_enabled  = false

  primary_network_interface {
    subnet = ibm_is_subnet.example.id
  }

  network_interfaces {
    name   = "eth1"
    subnet = ibm_is_subnet.example.id
    allow_ip_spoofing = false
  }

  vpc  = ibm_is_vpc.example.id
  zone = "jp-tok-1"
  keys = [ibm_is_ssh_key.example.id]

  //User can configure timeouts
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

#Transit gateway creation and connection to vpc

resource "ibm_tg_gateway" "new_tg_gw"{
name="${var.prefix}-transit-gateway"
location= var.region
global=true
} 

resource "ibm_tg_connection" "test_ibm_tg_connection" {
  gateway      = ibm_tg_gateway.new_tg_gw.id
  network_type = "vpc"
  name         = "${var.prefix}-conne-1"
  network_id   = ibm_is_vpc.example.crn
}

#Power infrastructure

locals {
  service_type = "power-iaas"
  plan         = "power-virtual-server-group"
  pvs_info = split(":", data.ibm_resource_instance.power_instance.id)
  location = local.pvs_info[5]
  region   = can(regex("-", local.location)) ? (can(regex("-[0-9]+$", local.location)) ? replace(local.location, regex("-[0-9]+$", local.location), "") : local.location) : (can(regex("[0-9]+$", local.location)) ? replace(local.location, regex("[0-9]+$", local.location), "") : local.location)
  pid      = local.pvs_info[7]

  stock_image_name = "VTL-FalconStor-10_03-001"
  catalog_image = [for x in data.ibm_pi_catalog_images.catalog_images.images : x if x.name == local.stock_image_name]
  private_image = [for x in data.ibm_pi_images.cloud_instance_images.image_info : x if x.name == local.stock_image_name]
  private_image_id = length(local.private_image) > 0 ? local.private_image[0].id  : ""
  placement_group = [for x in data.ibm_pi_placement_groups.cloud_instance_groups.placement_groups : x if x.name == var.vtl_placement_group]
  placement_group_id = length(local.placement_group) > 0 ? local.placement_group[0].id : ""

  images_length              = length(var.powervs_image_names)
  split_images_index         = ceil(local.images_length / 3)
  catalog_images_to_import_1 = flatten([for stock_image in data.ibm_pi_catalog_images.catalog_images_ds.images : [for image_name in slice(var.powervs_image_names, 0, local.split_images_index) : stock_image if stock_image.name == image_name]])
  catalog_images_to_import_2 = flatten([for stock_image in data.ibm_pi_catalog_images.catalog_images_ds.images : [for image_name in slice(var.powervs_image_names, 1, local.split_images_index) : stock_image if stock_image.name == image_name]])
  catalog_images_to_import_3 = flatten([for stock_image in data.ibm_pi_catalog_images.catalog_images_ds.images : [for image_name in slice(var.powervs_image_names, local.split_images_index, local.images_length) : stock_image if stock_image.name == image_name]])
  split_images_1             = slice(var.powervs_image_names, 0, local.split_images_index)
  split_images_2             = slice(var.powervs_image_names, 1, local.split_images_index)
  split_images_3             = slice(var.powervs_image_names, local.split_images_index, local.images_length)
}

#power workspace creation

data "ibm_resource_group" "resource_group_ds" {
  name = var.powervs_resource_group_name
}

resource "ibm_resource_instance" "powervs_workspace" {
  name              = "${var.prefix}-power-workspace"
  service           = local.service_type
  plan              = local.plan
  location          = var.powervs_zone
  resource_group_id = data.ibm_resource_group.resource_group_ds.id

  timeouts {
    create = "6m"
    update = "5m"
    delete = "10m"
  }
}

data "ibm_resource_instance" "power_instance" {
  name              = ibm_resource_instance.powervs_workspace.name
  
}


#####################################################
# Create Public and Private Subnets
#####################################################

resource "ibm_pi_network" "management_network" {
  provider  =  ibm.tile 
  pi_cloud_instance_id = local.pid
  pi_network_name      = var.powervs_management_network["name"]
  pi_cidr              = var.powervs_management_network["cidr"]
  pi_network_type      = "vlan"
}

resource "ibm_pi_network" "backup_network" {
  provider =  ibm.tile
  depends_on           = [ibm_pi_network.management_network]
  pi_cloud_instance_id = local.pid
  pi_network_name      = var.powervs_backup_network["name"]
  pi_cidr              = var.powervs_backup_network["cidr"]
  pi_network_type      = "vlan"
}

data "ibm_pi_network" "management_network" {
  provider =  ibm.tile
  pi_network_name = ibm_pi_network.management_network.pi_network_name
  pi_cloud_instance_id = local.pid
}
data "ibm_pi_network" "backup_network" {
  provider =  ibm.tile
  pi_network_name = ibm_pi_network.backup_network.pi_network_name
  pi_cloud_instance_id = local.pid
}

#Cloud Connection creation

resource "ibm_pi_cloud_connection" "cloud_connection" {
  provider =  ibm.tile
  pi_cloud_instance_id                = local.pid
  pi_cloud_connection_name            = "${var.prefix}-cloud-connection"
  pi_cloud_connection_speed           = var.cloud_connection["speed"]
  pi_cloud_connection_global_routing  = var.cloud_connection["global_routing"]
  pi_cloud_connection_metered         = var.cloud_connection["metered"]
  pi_cloud_connection_transit_enabled = true
  pi_cloud_connection_networks = [data.ibm_pi_network.management_network.id,data.ibm_pi_network.backup_network.id]
}

#Transit gateway connection to created Cloud Connection

data "ibm_tg_gateway" "tg_gateway_ds" {
  name = ibm_tg_gateway.new_tg_gw.name
}


data "ibm_dl_gateway" "gateway_ds_1" {
  depends_on = [ibm_pi_cloud_connection.cloud_connection]
  #count      = var.cloud_connection_count > 0 ? 1 : 0
  name       = ibm_pi_cloud_connection.cloud_connection.pi_cloud_connection_name
}

resource "time_sleep" "dl_1_resource_propagation" {
  depends_on      = [data.ibm_dl_gateway.gateway_ds_1]
  create_duration = "120s"
  triggers = {
    dl_crn = data.ibm_dl_gateway.gateway_ds_1.crn
  }
}

resource "ibm_tg_connection" "ibm_tg_connection_1" {
  depends_on   = [ibm_pi_cloud_connection.cloud_connection]
  gateway      = data.ibm_tg_gateway.tg_gateway_ds.id
  network_type = "directlink"
  name         = ibm_pi_cloud_connection.cloud_connection.pi_cloud_connection_name
  network_id   = time_sleep.dl_1_resource_propagation.triggers["dl_crn"]
}

#VTL instance creation

data "ibm_pi_catalog_images" "catalog_images" {
  provider             = ibm.tile
  sap                  = true
  vtl                  = true
  pi_cloud_instance_id = local.pid
}

data "ibm_pi_images" "cloud_instance_images" {
  provider             = ibm.tile
  pi_cloud_instance_id = local.pid
}

data "ibm_pi_placement_groups" "cloud_instance_groups" {
  provider             = ibm.tile
  pi_cloud_instance_id = local.pid
}

resource "ibm_pi_key" "sshkeys" {
  provider             = ibm.tile
  pi_cloud_instance_id = local.pid
  pi_key_name          = "${var.prefix}-vtl-sshkey"        
  pi_ssh_key           = var.vtl_public_key
}

resource "ibm_pi_image" "stock_image_copy" {
  provider             = ibm.tile
  count = length(local.private_image_id) == 0 ? 1 : 0
  pi_image_name       = local.stock_image_name
  pi_image_id         = local.catalog_image[0].image_id
  pi_cloud_instance_id = local.pid
}


resource "ibm_pi_network" "public_network" {
  provider             = ibm.tile
  count = length(var.vtl_public_network_name) > 0 ? 1 : 0
  pi_network_name      = var.vtl_public_network_name
  pi_cloud_instance_id = local.pid
  pi_network_type      = "pub-vlan" 
}

data "ibm_pi_network" "public_network" {
  provider             = ibm.tile
  count = length(var.vtl_public_network_name) > 0 ? 1 : 0
  pi_cloud_instance_id = local.pid
  pi_network_name      = ibm_pi_network.public_network[0].pi_network_name
}

resource "ibm_pi_instance" "instance" {
  provider             = ibm.tile
  pi_cloud_instance_id = local.pid
  pi_memory            = var.vtl_memory
  pi_processors        = var.vtl_processors
  pi_instance_name     = "${var.prefix}-vtl-instance"
  pi_proc_type         = var.vtl_processor_type
  pi_image_id          = length(local.private_image_id) == 0 ? ibm_pi_image.stock_image_copy[0].image_id : local.private_image_id
  pi_key_pair_name     = ibm_pi_key.sshkeys.pi_key_name
  pi_sys_type          = var.vtl_sys_type
  pi_storage_type      = var.vtl_storage_type
  pi_health_status    = "WARNING"
  pi_storage_pool     = "Tier1-Flash-2"
  pi_volume_ids  = [data.ibm_pi_volume.index_volume.id,data.ibm_pi_volume.tape_volume.id,data.ibm_pi_volume.configuration_volume.id]
  dynamic "pi_network" {
    for_each = var.vtl_public_network_name == "" ? [] : [1]
    content {
      network_id = data.ibm_pi_network.public_network[0].id
    }
  }
  pi_network {
    network_id = data.ibm_pi_network.management_network.id
  }
  dynamic "pi_network" {
    for_each = var.powervs_backup_network["name"] == "" ? [] : [1]
    content {
      network_id = data.ibm_pi_network.backup_network.id
    }
  }
}

resource "ibm_pi_volume" "index_volume"{
  pi_volume_size       = var.vtl_index_volume_size
  pi_volume_name       = "${var.prefix}-index-volume"
  pi_volume_type       = var.vtl_storage_type
  pi_volume_shareable  = true
  pi_cloud_instance_id = local.pid
}

data "ibm_pi_volume" "index_volume" {
  pi_volume_name       = ibm_pi_volume.index_volume.pi_volume_name
  pi_cloud_instance_id = local.pid
}

resource "ibm_pi_volume" "tape_volume"{
  pi_volume_size       = var.vtl_tape_volume_size
  pi_volume_name       = "${var.prefix}-tape-volume"
  pi_volume_type       = var.vtl_storage_type
  pi_volume_shareable  = true
  pi_cloud_instance_id = local.pid
}

data "ibm_pi_volume" "tape_volume" {
  pi_volume_name       = ibm_pi_volume.tape_volume.pi_volume_name
  pi_cloud_instance_id = local.pid
}

resource "ibm_pi_volume" "configuration_volume"{
  pi_volume_size       = var.vtl_configuration_volume_size
  pi_volume_name       = "${var.prefix}-configuration-volume"
  pi_volume_type       = var.vtl_storage_type
  pi_volume_shareable  = true
  pi_cloud_instance_id = local.pid
}

data "ibm_pi_volume" "configuration_volume" {
  pi_volume_name       = ibm_pi_volume.configuration_volume.pi_volume_name
  pi_cloud_instance_id = local.pid
}


#IBMI and AIX and Linux server creation


data "ibm_pi_catalog_images" "catalog_images_ds" {
  provider             = ibm.tile
  sap                  = true
  vtl                  = true
  pi_cloud_instance_id = local.pid
}

resource "ibm_pi_image" "import_images_1" {
  provider             = ibm.tile
  count                = length(local.split_images_1)
  pi_cloud_instance_id = local.pid
  pi_image_id          = local.catalog_images_to_import_1[count.index].image_id
  pi_image_name        = local.catalog_images_to_import_1[count.index].name

  timeouts {
    create = "9m"
  }
}

resource "ibm_pi_image" "import_images_2" {
  provider             = ibm.tile
  depends_on           = [ibm_pi_image.import_images_1]
  count                = length(local.split_images_2)
  pi_cloud_instance_id = local.pid
  pi_image_id          = local.catalog_images_to_import_2[count.index].image_id
  pi_image_name        = local.catalog_images_to_import_2[count.index].name

  timeouts {
    create = "9m"
  }
}

resource "ibm_pi_image" "import_images_3" {
  provider             = ibm.tile
  depends_on           = [ibm_pi_image.import_images_2]
  count                = length(local.split_images_3)
  pi_cloud_instance_id = local.pid
  pi_image_id          = local.catalog_images_to_import_3[count.index].image_id
  pi_image_name        = local.catalog_images_to_import_3[count.index].name

  timeouts {
    create = "9m"
  }
}


resource "ibm_pi_key" "linux_sshkey" {
  provider             = ibm.tile
  pi_key_name          = "${var.prefix}-linux-sshkey"
  pi_ssh_key           = var.linux_ssh_publickey
  pi_cloud_instance_id = local.pid
}


resource "ibm_pi_instance" "linux-instance" {
    provider             = ibm.tile
    pi_memory             = var.linux_memory
    pi_processors         = var.linux_processors
    pi_instance_name      = "${var.prefix}-linux-instance"
    pi_proc_type          = var.linux_proc_type
    count                 = length(local.split_images_1)
    pi_image_id           = ibm_pi_image.import_images_1[count.index].image_id
    pi_key_pair_name      = ibm_pi_key.linux_sshkey.pi_key_name
    pi_sys_type           = var.linux_sys_type
    pi_cloud_instance_id  = local.pid
    pi_pin_policy         = "none"
    pi_health_status      = "WARNING"
    pi_storage_type       = var.linux_storage_type
    pi_network {
      network_id = data.ibm_pi_network.backup_network.id
    }
}

resource "ibm_pi_key" "AIX_sshkey" {
  provider             = ibm.tile
  pi_key_name          = "${var.prefix}-AIX-sshkey"
  pi_ssh_key           = var.AIX_ssh_publickey
  pi_cloud_instance_id = local.pid
}

resource "ibm_pi_instance" "AIX-instance" {
    provider             = ibm.tile
    pi_memory             = var.AIX_memory
    pi_processors         = var.AIX_processors
    pi_instance_name      = "${var.prefix}-AIX-instance"
    pi_proc_type          = var.AIX_proc_type
    count                 = length(local.split_images_2)
    pi_image_id           = ibm_pi_image.import_images_2[count.index].image_id
    pi_key_pair_name      = ibm_pi_key.AIX_sshkey.pi_key_name
    pi_sys_type           = var.AIX_sys_type
    pi_cloud_instance_id  = local.pid
    pi_pin_policy         = "none"
    pi_health_status      = "WARNING"
    pi_storage_type       = var.AIX_storage_type
    pi_network {
      network_id = data.ibm_pi_network.backup_network.id
    }
}


resource "ibm_pi_key" "IBMI_sshkey" {
  provider             = ibm.tile
  pi_key_name          = "${var.prefix}-IBMI-sshkey"
  pi_ssh_key           = var.IBMI_ssh_publickey
  pi_cloud_instance_id = local.pid
}

resource "ibm_pi_instance" "IBMI-instance" {
    provider             = ibm.tile
    pi_memory             = var.IBMI_memory
    pi_processors         = var.IBMI_processors
    pi_instance_name      = "${var.prefix}-IBMI-Instance"
    pi_proc_type          = var.IBMI_proc_type
    count                 = length(local.split_images_3)
    pi_image_id           = ibm_pi_image.import_images_3[count.index].image_id
    pi_key_pair_name      = ibm_pi_key.IBMI_sshkey.pi_key_name
    pi_sys_type           = var.IBMI_sys_type
    pi_cloud_instance_id  = local.pid
    pi_pin_policy         = "none"
    pi_health_status      = "WARNING"
    pi_storage_type       = var.IBMI_storage_type
    pi_network {
      network_id = data.ibm_pi_network.backup_network.id
    }
}


