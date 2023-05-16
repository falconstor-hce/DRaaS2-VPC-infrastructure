provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

provider "ibm" {
  alias = "tile" 
  ibmcloud_api_key = var.ibmcloud_api_key
  region = local.region
  zone   = local.location
}
