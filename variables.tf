variable "organization_name" {
  type        = string
  default     = "my-org"
  description = "Organization name (O=<my-org>)"
}

variable "location" {
  type        = string
  description = "Azure Region where the resources should be created"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account"
}

variable "storage_account_replication_type" {
  type        = string
  default     = "LRS"
  description = "Storage account replication type. Valid options are LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Storage account replication type must be one of: LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  }
}

variable "law_name" {
  type        = string
  default     = null
  description = "Name for the Log Analytics Workspace"
}

variable "law_resource_group_name" {
  type        = string
  default     = null
  description = "Resource Group of existing Log Analytics Workspace"
}

variable "law_cross_subscription_details" {
  type = object({
    id           = string
    workspace_id = string
    shared_key   = string
  })
  default     = null
  nullable    = true
  description = "Used to reference an existing Log Analytics Workspace located in another subscription. Use this instead of law_name and law_resource_group_name."
  validation {
    condition     = var.law_cross_subscription_details == null || can(regex("^/subscriptions/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/resourceGroups/[^/]+/providers/Microsoft\\.OperationalInsights/workspaces/[^/]+$", var.law_cross_subscription_details.id))
    error_message = "When provided, law_cross_subscription_details.id must be a valid Log Analytics workspace resource ID."
  }
  validation {
    condition     = var.law_cross_subscription_details == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.law_cross_subscription_details.workspace_id))
    error_message = "When provided, law_cross_subscription_details.workspace_id must be a UUID."
  }
  validation {
    condition     = var.law_cross_subscription_details == null || length(trimspace(var.law_cross_subscription_details.shared_key)) > 0
    error_message = "When provided, law_cross_subscription_details.shared_key must be non-empty."
  }
  validation {
    condition     = var.law_cross_subscription_details == null || (var.law_name == null && var.law_resource_group_name == null)
    error_message = "When law_cross_subscription_details is provided, leave law_name and law_resource_group_name unset."
  }
  validation {
    condition     = var.law_cross_subscription_details != null || var.law_name != null
    error_message = "Set law_name when using workspaces from the current subscription."
  }
}

variable "service_plan_name" {
  type        = string
  description = "Name of the service plan"
}

variable "service_plan_sku" {
  type        = string
  default     = "S1"
  description = "SKU for App Service Plan"
}

variable "service_plan_os_type" {
  type    = string
  default = "Windows"
  validation {
    condition     = can(regex("Windows|Linux", var.service_plan_os_type))
    error_message = "service_plan_os_type must be either 'Windows' or 'Linux'"
  }
  description = "The type of operating system to use for the app service plan. Possible values are 'Windows' or 'Linux'."
}

variable "service_plan_resource_id" {
  type        = string
  default     = null
  description = "Resource ID of the service plan"
}

variable "enable_application_insights" {
  type        = bool
  default     = false
  description = "Should Terraform create and connect Application Insights for the App services? NOTE: This will prevent Terraform from beeing able to destroy the ressource group!"
}

variable "app_service_retention_in_days" {
  type        = number
  default     = 90
  description = "How many days http_logs should be kept"
}

variable "app_service_retention_in_mb" {
  type        = number
  default     = 35
  description = "Max file size of http_logs"
}

variable "app_service_logs_detailed_error_messages" {
  type        = bool
  default     = true
  description = "Detailed Error messages of the app service"
}

variable "app_service_logs_failed_request_tracing" {
  type        = bool
  default     = false
  description = "Trace failed requests"
}

variable "app_service_application_logs_file_system_level" {
  type        = string
  default     = "Error"
  description = "Application Log level for file_system"
}

variable "app_service_name_primary" {
  type        = string
  description = "Name of the primary app service"
}

variable "app_service_minimum_tls_version_scepman" {
  type        = string
  default     = "1.2"
  description = "Minimum Inbound TLS Version for SCEPman core App Service"

  validation {
    condition     = contains(["1.0", "1.1", "1.2", "1.3"], var.app_service_minimum_tls_version_scepman)
    error_message = "The TLS version must be one of: 1.0, 1.1, 1.2, or 1.3."
  }
}

variable "app_service_minimum_tls_version_certificate_master" {
  type        = string
  default     = "1.3"
  description = "Minimum Inbound TLS Version for Certificate Master App Service"

  validation {
    condition     = contains(["1.0", "1.1", "1.2", "1.3"], var.app_service_minimum_tls_version_certificate_master)
    error_message = "The TLS version must be one of: 1.0, 1.1, 1.2, or 1.3."
  }
}

variable "app_service_name_certificate_master" {
  type        = string
  description = "Name of the certificate master app service"
}

variable "key_vault_name" {
  type        = string
  description = "Name of the key vault"
}

variable "key_vault_use_rbac" {
  type        = bool
  default     = true
  description = "Use RBAC for the key vault or the older access policies"
}

variable "vnet_name" {
  type        = string
  default     = "vnet-scepman"
  description = "Name of the VNET created for internal communication"
}

variable "vnet_address_space" {
  type        = list(any)
  default     = ["10.158.200.0/24"]
  description = "Address-Space of the VNET"
}

variable "subnet_appservices_name" {
  type        = string
  default     = "snet-scepman-appservices"
  description = "Name of the subnet created for integrating the App Services"
}

variable "subnet_endpoints_name" {
  type        = string
  default     = "snet-scepman-endpoints"
  description = "Name of the subnet created for the other endpoints"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resource"
}

variable "artifacts_url_primary" {
  type        = string
  default     = "https://raw.githubusercontent.com/scepman/install/master/dist/Artifacts.zip"
  description = "URL of the artifacts for SCEPman"
}

variable "artifacts_url_certificate_master" {
  type        = string
  default     = "https://raw.githubusercontent.com/scepman/install/master/dist-certmaster/CertMaster-Artifacts.zip"
  description = "URL of the artifacts for SCEPman Certificate Master"
}
variable "app_settings_primary" {
  type        = map(string)
  default     = {}
  description = "A mapping of app settings to assign to the primary app service"
}

variable "app_settings_certificate_master" {
  type        = map(string)
  default     = {}
  description = "A mapping of app settings to assign to the certificate master app service"
}
