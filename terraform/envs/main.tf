provider "azurerm" {
  version = "2.59.0"
  features {}
}

locals {
  appname         = "aptestapp"
  environment     = "staging"
  primaryregion   = "ukwest"

}

module "aptestapp" {
  source = "../"

  #-----------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------

  appname              = local.appname
  environment          = local.environment
  primaryregion        = local.primaryregion

}