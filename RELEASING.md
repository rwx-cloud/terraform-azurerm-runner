# Releasing

The public source repository is `rwx-cloud/terraform-azurerm-runner`. Publishing
Git source is separate from approving a version tag or Terraform Registry release.
Before a Registry release, confirm public RWX CI is enabled and select this
repository in Terraform Registry under `rwx-cloud` with explicit approval.

Before approving an initial `v1.0.0` tag:

1. Run all CI checks and the basic example validation through RWX.
2. Apply to a disposable, billing-enabled Azure subscription with approval.
3. Record and replay Cloud's actual Azure integration tests, including wrong
   issuer/subject/audience and denied access to a different resource group/subnet.
4. Complete staging bootstrap and a real task with DNS (UDP and TCP), HTTPS,
   filesystem/quota checks, and verified VM/NIC/disk cleanup.
5. Review generated input/output documentation against the Terraform schema.

Only then approve publishing the tag and verify that
`rwx-cloud/runner/azurerm` resolves from a clean `terraform init`. A Git tag alone
does not publish the module to the Registry. Never advertise an unpublished source
as working setup instructions.
