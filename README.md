# SCEPman - Certificates Simplified

[SCEPman Docs](https://docs.scepman.com)

SCEPman is a slim and resource-friendly solution to issue and validate certificates using SCEP.
It is an Azure Web App providing the SCEP protocol and works directly with the Microsoft Graph and Intune API. SCEPman uses an Azure Key Vault based Root CA and certificate creation. No other component is involved, neither a database nor any other stateful storage except the Azure Key Vault itself. That said, SCEPman will not need any backup procedures or other operation level tasks. Only an Azure subscription is necessary to deploy it.

## Prerequisites

- Access to an **Azure subscription** (or Resource Group) with `Owner` RBAC Role assigned to Principal used for deployment
- Terraform environment - local, GitHub Codespaces or Dev Containers

#### Local Environment:

- Setup your **environment** using the following guide [Getting Started](https://learn.microsoft.com/en-us/azure/developer/terraform/quickstart-configure)

#### GitHub Codespaces

- Repository contains GitHub [Codespaces](https://github.com/features/codespaces) dev container definitions

[Open in GitHub Codespaces](https://github.com/codespaces/new?hide_repo_select=true&repo=scepman%2Fterraform-azurerm-scepman)

#### Dev Containers

Visit [containers.dev](https://containers.dev) for more information

## Terraform State

- You can use local Terraform state for demo purposes
- We recommend to [Store Terraform state in Azure Storage](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) for your Production environment
<!-- BEGIN_TF_DOCS -->


## Examples

### Advanced

For more informations how to deploy the following example, see the [Advanced Example Documentation](examples/advanced/).

```hcl
# Version requirements

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.8"
    }
  }
  backend "local" {}

  required_version = ">= 1.3"
}

# Provider configuration

provider "azurerm" {
  features {}
  partner_id = "a262352f-52a9-4ed9-a9ba-6a2b2478d19b"
}

# Resources

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

module "scepman" {
  # Option 1: Local module, use from local development
  # source = "../.." # This is the local path to the module

  # Option 2: Use the terraform registry version
  source = "scepman/scepman/azurerm"
  # version = "0.1.0"


  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  storage_account_name = var.storage_account_name
  key_vault_name       = var.key_vault_name
  law_name             = var.law_name

  service_plan_os_type                = "Windows"
  service_plan_name                   = var.service_plan_name
  app_service_name_primary            = var.app_service_name_primary
  app_service_name_certificate_master = var.app_service_name_certificate_master

  app_settings_primary            = var.app_settings_primary
  app_settings_certificate_master = var.app_settings_certificate_master

  tags = var.tags
}
```

## Inputs

| Name                                                                                                                                                | Description                                                               | Type          | Default                                                                                               | Required |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ------------- | ----------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_app_service_name_certificate_master"></a> [app\_service\_name\_certificate\_master](#input\_app\_service\_name\_certificate\_master) | Name of the certificate master app service                                | `string`      | n/a                                                                                                   |   yes    |
| <a name="input_app_service_name_primary"></a> [app\_service\_name\_primary](#input\_app\_service\_name\_primary)                                    | Name of the primary app service                                           | `string`      | n/a                                                                                                   |   yes    |
| <a name="input_app_service_minimum_tls_version_scepman"></a> [app\_service\_minimum\_tls\_version\_scepman](#input\_app\_service\_minimum\_tls\_version\_scepman) | Minimum Inbound TLS Version for SCEPman core App Service                 | `string`      | `1.2`                                                                                                  |    no    |
| <a name="input_app_service_minimum_tls_version_certificate_master"></a> [app\_service\_minimum\_tls\_version\_certificate\_master](#input\_app\_service\_minimum\_tls\_version\_certificate\_master) | Minimum Inbound TLS Version for Certificate Master App Service           | `string`      | `1.3`                                                                                                  |    no    |
| <a name="input_app_settings_certificate_master"></a> [app\_settings\_certificate\_master](#input\_app\_settings\_certificate\_master)               | A mapping of app settings to assign to the certificate master app service | `map(string)` | `{}`                                                                                                  |    no    |
| <a name="input_app_settings_primary"></a> [app\_settings\_primary](#input\_app\_settings\_primary)                                                  | A mapping of app settings to assign to the primary app service            | `map(string)` | `{}`                                                                                                  |    no    |
| <a name="input_artifacts_url_primary"></a> [artifacts\_url\_primary](#input\_artifacts\_url\_primary)                                               | URL to the artifacts of the primary SCEPman Service                       | `string`      | `"https://raw.githubusercontent.com/scepman/install/master/dist/Artifacts.zip"`                       |    no    |
| <a name="input_artifacts_url_certificate_master"></a> [artifacts\_url\_certificate\_master](#input\_artifacts\_url\_certificate\_master)            | URL to the artifacts of the SCEPman certificate master                    | `string`      | `"https://raw.githubusercontent.com/scepman/install/master/dist-certmaster/CertMaster-Artifacts.zip"` |    no    |
| <a name="input_law_name"></a> [law\_name](#input\_law\_name)                                                                                        | Name of the Log Analytics Workspace                                       | `string`      | n/a                                                                                                   |   yes    |
| <a name="input_law_resource_group"></a> [law\_resource\_group](#input\_law\_resource\_group)                                                        | Resource Group of existing Log Analytics Workspace                        | `string`      | `null`                                                                                                |    no    |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name)                                                                    | Name of the key vault                                                     | `string`      | n/a                                                                                                   |   yes    |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name)                                                                                     | Name of VNET created for internal communication                           | `string`      | vnet-scepman                                                                                          |    no    |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space)                                                        | Address-Space of the VNET (needs to be /27 or larger)                                                 | `list(any)`   | ["10.158.200.0/24"]                                                                                   |    no    |
| <a name="input_subnet_appservices_name"></a> [subnet\_appservices\_name](#input\_subnet\_appservices\_name)                                         | Name of the subnet created for integrating the App Services               | `string`      | snet-scepman-appservices                                                                              |    no    |
| <a name="input_subnet_endpoints_name"></a> [subnet\_endpoints\_name](#input\_subnet\_endpoints\_name)                                               | Name of the subnet created for the other endpoints                        | `string`      | snet-scepman-endpoints                                                                                |    no    |
| <a name="input_location"></a> [location](#input\_location)                                                                                          | Azure Region where the resources should be created                        | `string`      | n/a                                                                                                   |   yes    |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)                                                     | Name of the resource group                                                | `string`      | n/a                                                                                                   |   yes    |
| <a name="input_service_plan_name"></a> [service\_plan\_name](#input\_service\_plan\_name)                                                           | Name of the service plan                                                  | `string`      | n/a                                                                                                   |   yes    |
| <a name="input_service_plan_os_type"></a> [service\_plan\_os\_type](#input\_service\_plan\_os\_type)                                                              | OS of the service plan. Either "Windows" or "Linux"                                                   | `string`      | `Windows`                                                                                                  |    no    |
| <a name="input_service_plan_sku"></a> [service\_plan\_sku](#input\_service\_plan\_sku)                                                              | SKU of the service plan                                                   | `string`      | `S1`                                                                                                  |    no    |
| <a name="input_service_plan_resource_id"></a> [service\_plan\_resource\_id](#input\_service\_plan\_resource\_id)                                    | Resource ID of the service plan                                           | `string`      | `null`                                                                                                |    no    |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name)                                                  | Name of the storage account                                               | `string`      | n/a                                                                                                   |   yes    |
| <a name="input_storage_account_replication_type"></a> [storage\_account\_replication\_type](#input\_storage\_account\_replication\_type)           | Storage account replication type. Valid options are LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS. | `string`      | `LRS`                                                                                                 |    no    |
| <a name="input_organization_name"></a> [organization\_name](#input\organization\_name)                                                              | Your organization name presented in the O= field of the root certificate  | `string`      | `my-org`                                                                                              |    no    |
| <a name="input_key_vault_use_rbac"></a> [key\_vault\_use\_rbac](#input\_key\_vault\_use\_rbac)                                                        | Use RBAC for the key vault or the older access policies                   | `bool`        | `true`                                                                                                |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                                      | A mapping of tags to assign to the resource                               | `map(string)` | `{}`                                                                                                  |    no    |


### Optional App Service Logging settings

| Name                                                                                                                                                                                     | Description                                                                                                                                      | Type     | Default   | Required |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | --------- | :------: |
| <a name="input_enable_application_insights"></a> [enable\_application\_insights](#input\_enable\_application\_insights)                                                                  | Create and connect Application Insights for the App services. NOTE: This will prevent Terraform from beeing able to destroy the ressource group! | `bool`   | `false`   |    no    |
| <a name="input_app_service_retention_in_days"></a> [app\_service\_retention\_in\_days](#input\_app\_service\_retention\_in\_days)                                                        | Retention of http_logs in days                                                                                                                   | `number` | `180`     |    no    |
| <a name="input_app_service_retention_in_mb"></a> [app\_service\_retention\_in\_mb](#input\_app\_service\_retention\_in\_mb)                                                              | Retention of http_logs in mb                                                                                                                     | `number` | `35`      |    no    |
| <a name="input_app_service_logs_detailed_error_messages"></a> [app\_service\_logs\_detailed\_error\_messages](#input\_app\_service\_logs\_detailed\_error\_messages)                     | Detailed Error messages of the app service                                                                                                       | `bool`   | `true`    |    no    |
| <a name="input_app_service_logs_failed_request_tracing"></a> [app\_service\_logs\_failed\_request\_tracing](#input\_app\_service\_logs\_failed\_request\_tracing)                        | Trace failed requests                                                                                                                            | `bool`   | `false`   |    no    |
| <a name="input_app_service_application_logs_file_system_level"></a> [app\_service\_application\_logs\_file\_system\_level](#input\_app\_service\_application\_logs\_file\_system\_level) | Application Log level for file_system                                                                                                            | `string` | `"Error"` |    no    |


## Outputs

| Name                                                                                                                                 | Description                    |
| ------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------ |
| <a name="output_scepman_certificate_master_url"></a> [scepman\_certificate\_master\_url](#output\_scepman\_certificate\_master\_url) | SCEPman Certificate Master Url |
| <a name="output_scepman_url"></a> [scepman\_url](#output\_scepman\_url)                                                              | SCEPman Url                    |
<!-- END_TF_DOCS -->
