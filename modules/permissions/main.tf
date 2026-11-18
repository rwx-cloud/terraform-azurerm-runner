# Azure Compute RBAC cannot enforce GCP's rwx- name condition. The dedicated
# resource group, rather than a resource-name prefix, is the isolation boundary.
resource "azurerm_role_definition" "provisioning" {
  name        = "rwx-provisioning-${var.name_suffix}"
  scope       = var.resource_group_id
  description = "Manage RWX runner VMs, NICs, disks, and public IPs in a dedicated resource group."
  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/write",
      "Microsoft.Compute/virtualMachines/delete",
      "Microsoft.Compute/virtualMachines/instanceView/read",
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/delete",
      "Microsoft.Compute/locations/operations/read",
      "Microsoft.Compute/locations/diskOperations/read",
      "Microsoft.Network/networkInterfaces/read",
      "Microsoft.Network/networkInterfaces/write",
      "Microsoft.Network/networkInterfaces/delete",
      "Microsoft.Network/networkInterfaces/join/action",
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Network/publicIPAddresses/write",
      "Microsoft.Network/publicIPAddresses/delete",
      "Microsoft.Network/publicIPAddresses/join/action",
      "Microsoft.Network/locations/operations/read",
      "Microsoft.Network/locations/operationResults/read",
    ]
  }
  assignable_scopes = [var.resource_group_id]
}

resource "azurerm_role_assignment" "provisioning" {
  scope              = var.resource_group_id
  role_definition_id = azurerm_role_definition.provisioning.role_definition_resource_id
  principal_id       = var.principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_definition" "subnet" {
  name  = "rwx-subnet-${var.name_suffix}"
  scope = var.subnet_id
  permissions {
    actions = [
      "Microsoft.Network/virtualNetworks/subnets/read",
      "Microsoft.Network/virtualNetworks/subnets/join/action",
    ]
  }
  assignable_scopes = [var.subnet_id]
}

resource "azurerm_role_assignment" "subnet" {
  scope              = var.subnet_id
  role_definition_id = azurerm_role_definition.subnet.role_definition_resource_id
  principal_id       = var.principal_id
  principal_type     = "ServicePrincipal"
}
