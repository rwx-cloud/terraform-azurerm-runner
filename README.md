# RWX Azure self-hosted runner

Terraform module for RWX Azure self-hosted runners. Until a Registry release is
published, use this Git repository pinned to a reviewed full commit SHA:
`git::https://github.com/rwx-cloud/terraform-azurerm-runner.git?ref=<commit-sha>`.
Replace `<commit-sha>` with the actual reviewed commit. The intended Registry
source is `rwx-cloud/runner/azurerm`; no Registry release is published yet.

## Setup

1. Create an RWX Azure runner configuration with your tenant, subscription,
   dedicated resource group, location, ordered zones, and subnet ARM ID. Copy its
   label, external ID, and exact OIDC issuer.
2. Apply this module as an administrator allowed to create managed identities,
   custom roles, and role assignments. Register `Microsoft.Compute`,
   `Microsoft.Network`, and `Microsoft.ManagedIdentity` beforehand. The caller's
   AzureRM provider selects the subscription; disable automatic registration for
   least-privileged CI identities.
3. Copy the `provisioning_client_id` output back into RWX. Azure assigns this UUID;
   it cannot be calculated from the managed identity name. It is not a secret.
4. Select a supported SKU and zones available to your subscription. Initially
   coordinate `eastus2` with RWX's image replication regions; do not assume every
   subscription can run the same SKU in all three zones.

See [examples/basic](examples/basic/main.tf). This module does not create the
network or VMs. The subnet must be in the runner subscription and region and have
explicit outbound connectivity, typically a NAT Gateway, for DNS, HTTPS, RWX
configuration, task servers, binaries, layers, and logs. No inbound rule or
public VM IP is required. Network security groups should deny unsolicited inbound
traffic, including traffic from neighboring VMs.

## Security boundary

The provisioner is `rwx-provisioning-<last 12 characters of external ID>` and trusts
only `rwx:provisioning:<full external ID>` from the exact issuer, with audience
`api://AzureADTokenExchange`. No client secret, tenant application, or runtime VM
managed identity is created. Never attach the provisioning identity to a VM.

**The resource group must contain only this runner configuration's resources.**
Unlike GCP's IAM condition, Azure Compute RBAC does not restrict these grants to
`rwx-` names. The custom role can create/read/delete VMs, NICs, and disks throughout
the resource group, with operation polling permissions; it cannot change RBAC,
create public IPs, or modify the network. A separate role grants read/join on the
one supplied subnet. Do not put unrelated workloads in the runner group.

VM authentication uses Cloud's verification of a signed IMDS attested document,
not a shared managed-identity access token. WAF header presence is not authentication.
Boot diagnostics uses Azure-managed storage; no storage account is required.

Image versions are immutable Community Gallery references, replicated to every
selected runner region. Public availability does not override your subscription's
Azure Policy restrictions. The Gen2 gallery definition is `TrustedLaunchSupported`,
not `TrustedLaunch`: Mint captures Standard-security builders without VMGS, and
builders and runners keep Secure Boot off for the unsigned rwxfs kernel module.
Gallery publication is a separate RWX operation.

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
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing dedicated resource group containing only this configuration's runner VMs, NICs, disks, and provisioning identity. | `string` | n/a | yes |
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

## Verification

Run `rwx run .rwx/ci.yml --wait` for recursive formatting,
`terraform init -backend=false`, and `terraform validate` for this module and the
basic example. Do not replace real Azure permission tests with
mock plans: Cloud's live VCR recording must prove federation, private VM creation,
polling, idempotent cleanup of VM/NIC/disk, and denied access outside the runner
resource group. Replay only proves the recorded API contract, not a fresh Azure
deployment. The infrastructure repository's `modules/azure-runner-foundation/README.md`
documents recording prerequisites and smoke steps. Regenerate the schema tables
with `terraform-docs markdown table --output-file README.md --output-mode inject .`
from this module using terraform-docs 0.20.0 in an RWX sandbox.
