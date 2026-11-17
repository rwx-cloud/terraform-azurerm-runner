terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

variable "subscription_id" {
  description = "Billing-enabled Azure subscription with Compute, Network, and ManagedIdentity providers registered."
  type        = string
}

variable "runner" {
  description = "Values shown on the RWX runner configuration and the existing dedicated resource group/subnet."
  type = object({
    label               = string
    external_id         = string
    issuer              = string
    resource_group_name = string
    location            = string
    subnet_id           = string
  })
}

module "runner" {
  source = "../.."

  rwx_self_hosted_runner_label       = var.runner.label
  rwx_self_hosted_runner_external_id = var.runner.external_id
  rwx_oidc_issuer                    = var.runner.issuer
  resource_group_name                = var.runner.resource_group_name
  location                           = var.runner.location
  subnet_id                          = var.runner.subnet_id
}

output "provisioning_client_id" {
  description = "Copy this UUID to RWX after apply."
  value       = module.runner.provisioning_client_id
}
