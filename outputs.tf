output "provisioning_client_id" {
  description = "Save this Azure-generated UUID on the RWX runner configuration after applying. It cannot be derived from the identity name."
  value       = azurerm_user_assigned_identity.provisioning.client_id
}

output "provisioning_identity_id" {
  description = "ARM ID of the provisioning identity. Do not attach this identity to runner VMs."
  value       = azurerm_user_assigned_identity.provisioning.id
}
