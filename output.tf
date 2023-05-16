output "access_key_id" {
  value = nonsensitive(ibm_resource_key.key.credentials["cos_hmac_keys.access_key_id"])
}
output "secret_access_key" {
  value = nonsensitive(ibm_resource_key.key.credentials["cos_hmac_keys.secret_access_key"])
}