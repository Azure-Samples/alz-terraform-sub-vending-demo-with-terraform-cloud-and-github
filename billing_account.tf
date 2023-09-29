locals {
  is_billing_ea  = var.billing_account_type == "ea"
  is_billing_mca = var.billing_account_type == "mca"
  is_billing_mpa = var.billing_account_type == "mpa"
}

data "azurerm_billing_enrollment_account_scope" "vending" {
  count                   = local.is_billing_ea ? 1 : 0
  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.billing_enrollment_account_name
}

data "azurerm_billing_mca_account_scope" "vending" {
  count                = local.is_billing_mca ? 1 : 0
  billing_account_name = var.billing_account_name
  billing_profile_name = var.billing_profile_name
  invoice_section_name = var.billing_invoice_section_name
}

data "azurerm_billing_mpa_account_scope" "vending" {
  count                = local.is_billing_mpa ? 1 : 0
  billing_account_name = var.billing_account_name
  customer_name        = var.billing_customer_name
}

locals {
  billing_scope_ea  = local.is_billing_ea ? data.azurerm_billing_enrollment_account_scope.vending[0].id : null
  billing_scope_mca = local.is_billing_mca ? data.azurerm_billing_mca_account_scope.vending[0].id : null
  billing_scope_mpa = local.is_billing_mpa ? data.azurerm_billing_mpa_account_scope.vending[0].id : null
  billing_scope     = coalesce(local.billing_scope_ea, local.billing_scope_mca, local.billing_scope_mpa)
}