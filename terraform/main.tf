terraform {
}

provider "azurerm" {
  version = "~> 2.59"
  features {}
}

data "azurerm_subscription" "main" {
}

data "azurerm_client_config" "main" {
}

#resource group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.appname}-${var.environment}"
  location = var.primaryregion
}

#app insights
resource "azurerm_application_insights" "main" {
  name                = "appi-${var.appname}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type = "web"
}

#storage account
resource "azurerm_storage_account" "main" {
  name                      = "sa${var.appname}${var.environment}"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
}

#app service plan
resource "azurerm_app_service_plan" "main" {
  name                = "plan-${var.appname}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Windows"

  sku {
    tier = "Free"
    size = "F1"
  }
}

#app service
resource "azurerm_app_service" "main" {
  name                = "app-${var.appname}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id
  https_only          = true

  app_settings = {
        "ApplicationInsights:InstrumentationKey" = azurerm_application_insights.main.instrumentation_key
        "APPINSIGHTS_PROFILERFEATURE_VERSION" = "1.0.0"
        "APPINSIGHTS_SNAPSHOTFEATURE_VERSION" = "1.0.0"
        "APPLICATIONINSIGHTS_CONNECTION_STRING" = "InstrumentationKey=${azurerm_application_insights.main.instrumentation_key}"
        "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
        "DiagnosticServices_EXTENSION_VERSION" = "~3"
        "InstrumentationEngine_EXTENSION_VERSION" = "disabled"
        "SnapshotDebugger_EXTENSION_VERSION" = "disabled"
        "XDT_MicrosoftApplicationInsights_BaseExtensions" = "disabled"
        "XDT_MicrosoftApplicationInsights_Mode" = "recommended"
        "XDT_MicrosoftApplicationInsights_PreemptSdk" = "1"
        "BlobConnection" = azurerm_storage_account.main.primary_blob_endpoint
    }

   site_config {
         ftps_state = "Disabled"
         use_32_bit_worker_process = true
   }

   identity {
     type = "SystemAssigned"
   }

   logs {
     detailed_error_messages_enabled = true
     failed_request_tracing_enabled  = true
     http_logs {
       file_system {
         retention_in_days = 30
         retention_in_mb   = 100
       }
     }
   }
}

resource "azurerm_role_assignment" "main" {
  scope                = azurerm_storage_container.imagescontainer.resource_manager_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = "${azurerm_app_service.main.identity.0.principal_id}"
}