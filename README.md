# terraform-azurerm-runner

Grants [RWX](https://www.rwx.com) permission to provision self-hosted runners in
your Azure subscription. Contact [RWX support](https://www.rwx.com/support) to
enable support for self-hosted runners.

The module creates a managed identity, a federated credential, and two custom
roles with assignments. It does not create networks or VMs — RWX launches runners
into the subnet you specify.

- **Provisioning identity** — RWX uses this identity to manage runner VMs,
  network interfaces, disks, and public IPs. It trusts only your runner's external
  ID. Its provisioning role is scoped to the resource group you specify.
- **Subnet role** — allows the provisioning identity to read and join only the
  subnet you specify. It cannot change the subnet or its security rules.

**The resource group must be dedicated to this RWX runner configuration.**
The provisioning role can manage resources throughout that group, so do not put
unrelated workloads there.

## Usage

Contact [RWX support](https://www.rwx.com/support) to enable support for
self-hosted runners.

Create a self-hosted Azure runner at [cloud.rwx.com](https://cloud.rwx.com), then
apply this module with the values it shows you. Replace the example subscription,
issuer, resource group, and subnet below with your own values:

```hcl
provider "azurerm" {
  features {}
  subscription_id = "<subscription-id>"
}

module "rwx_runner" {
  source  = "rwx-cloud/runner/azurerm"
  version = "~> 1.0"

  rwx_self_hosted_runner_label       = "prod"
  rwx_self_hosted_runner_external_id = "8f4c1d92a7b3e5604fa8c2d19e0b7635"
  rwx_oidc_issuer                    = "https://issuer.example.com"
  resource_group_name                = "rwx-runners"
  location                           = "eastus2"
  subnet_id                          = "/subscriptions/<subscription-id>/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/runners/subnets/runners"
}
```

The module uses the subscription selected by your `azurerm` provider. The resource
group and subnet must already exist, and the subnet must be in that subscription
and the runner's region. Apply with permission to create managed identities,
custom roles, and role assignments. Then copy the `provisioning_client_id` output
back into RWX.

Runners need outbound internet access through a public IP or a NAT Gateway.
No inbound access is required; keep your network security groups blocking
unsolicited traffic, including SSH.

### Granting your builds access to other Azure resources

Use OIDC. Do not attach the provisioning identity to runner VMs or use it for
builds. Add an OIDC token to an RWX vault with audience
`api://AzureADTokenExchange`, then create a separate Azure identity that trusts
the token's issuer and subject. Grant that identity only the permissions your
builds need.

## Upgrading

RWX occasionally releases features that need additional permissions. To upgrade,
raise the `version` constraint, run `terraform init -upgrade`, and review and
apply the plan.

## Examples

- [Basic](examples/basic) - A single runner in one subscription and region

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_permissions"></a> [permissions](#module\_permissions) | ./modules/permissions | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.rwx](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_user_assigned_identity.provisioning](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region of the runner resource group and subnet, for example eastus2. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing dedicated resource group containing only this configuration's runner VMs, NICs, disks, public IPs, and provisioning identity. | `string` | n/a | yes |
| <a name="input_rwx_oidc_issuer"></a> [rwx\_oidc\_issuer](#input\_rwx\_oidc\_issuer) | Public HTTPS OIDC issuer shown by RWX; preserve its exact spelling. | `string` | n/a | yes |
| <a name="input_rwx_self_hosted_runner_external_id"></a> [rwx\_self\_hosted\_runner\_external\_id](#input\_rwx\_self\_hosted\_runner\_external\_id) | 32-character external ID generated by RWX for this runner configuration. | `string` | n/a | yes |
| <a name="input_rwx_self_hosted_runner_label"></a> [rwx\_self\_hosted\_runner\_label](#input\_rwx\_self\_hosted\_runner\_label) | Self-hosted runner label shown in RWX. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Full ARM ID of the existing subnet; it must have outbound internet access and be in the runner subscription and region. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_provisioning_client_id"></a> [provisioning\_client\_id](#output\_provisioning\_client\_id) | Save this Azure-generated UUID on the RWX runner configuration after applying. It cannot be derived from the identity name. |
| <a name="output_provisioning_identity_id"></a> [provisioning\_identity\_id](#output\_provisioning\_identity\_id) | ARM ID of the provisioning identity. Do not attach this identity to runner VMs. |
<!-- END_TF_DOCS -->

## License

MIT. See [LICENSE](LICENSE).
