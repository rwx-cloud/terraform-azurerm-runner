data "azurerm_subscription" "current" {}

locals {
  name_suffix       = substr(var.rwx_self_hosted_runner_external_id, 20, 12)
  resource_group_id = "${data.azurerm_subscription.current.id}/resourceGroups/${var.resource_group_name}"
}

resource "azurerm_user_assigned_identity" "provisioning" {
  name                = "rwx-provisioning-${local.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = { "rwx-runner" = var.rwx_self_hosted_runner_label }
}

resource "azurerm_federated_identity_credential" "rwx" {
  name                = "rwx-cloud"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.provisioning.id
  issuer              = var.rwx_oidc_issuer
  subject             = "rwx:provisioning:${var.rwx_self_hosted_runner_external_id}"
  audience            = ["api://AzureADTokenExchange"]
}

module "permissions" {
  source            = "./modules/permissions"
  name_suffix       = local.name_suffix
  resource_group_id = local.resource_group_id
  subnet_id         = var.subnet_id
  principal_id      = azurerm_user_assigned_identity.provisioning.principal_id
}
