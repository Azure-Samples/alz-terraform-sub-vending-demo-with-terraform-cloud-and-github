module "terraform_cloud_workspace" {
  source                  = "./modules/tfworkspace"
  workspace_name          = local.terraform_cloud_workspace_name
  organisation            = var.terraform_cloud_organisation
  project_name            = var.terraform_cloud_user_project
  arm_subscription_id     = module.lz_vending.subscription_id
  arm_tenant_id           = data.azuread_client_config.current.tenant_id
  tfc_azure_run_client_id = module.lz_vending.umi_client_id
  resource_group_name     = [ for key, resource_group in var.resource_groups : resource_group.name if resource_group.primary ][0]
}

module "lz_vending" {
  source  = "Azure/lz-vending/azurerm"
  version = "3.4.1"

  # Manage NW RG within Vending
  network_watcher_resource_group_enabled = true

  # Register providers
  subscription_register_resource_providers_enabled = true

  # Set the default location for resources
  location = var.location

  # subscription variables
  subscription_alias_enabled = true
  subscription_billing_scope = local.billing_scope
  subscription_display_name  = var.subscription_name
  subscription_alias_name    = var.subscription_name
  subscription_workload      = var.subscription_offer

  # management group association variables
  subscription_management_group_association_enabled = true
  subscription_management_group_id                  = data.azurerm_management_group.vending.name

  # role assignments
  role_assignment_enabled = true
  role_assignments        = local.subscription_user_owners

  # user assigned managed identity
  umi_enabled             = true
  umi_name                = local.user_assigned_managed_identity_name
  umi_resource_group_name = local.identity_resource_group_name
  umi_role_assignments = { for key, resource_group in var.resource_groups : key => {
    definition     = "Contributor"
    relative_scope = "/resourceGroups/${resource_group.name}"
    }
  }
  umi_federated_credentials_terraform_cloud = {
    plan = {
      name         = "${var.subscription_name}-plan"
      organization = var.terraform_cloud_organisation
      project      = var.terraform_cloud_user_project
      workspace    = local.terraform_cloud_workspace_name
      run_phase    = "plan"
    }
    apply = {
      name         = "${var.subscription_name}-apply"
      organization = var.terraform_cloud_organisation
      project      = var.terraform_cloud_user_project
      workspace    = local.terraform_cloud_workspace_name
      run_phase    = "apply"
    }
  }

  # resource groups
  resource_group_creation_enabled = true
  resource_groups                 = { for key, resource_group in var.resource_groups :key => {
      name     = resource_group.name
      location = resource_group.location
    }
  }
}

module "github" {
  source                         = "./modules/github"
  repository_name                = local.github_repository_name
  repository_description         = local.github_repository_name
  repository_organisation        = var.repository_organisation
  template_organisation          = var.persona_template_organisation
  template_repository            = var.persona_template_repository
  terraform_cloud_organisation   = var.terraform_cloud_organisation
  terraform_cloud_workspace_name = local.terraform_cloud_workspace_name
  terraform_cloud_access_token   = module.terraform_cloud_workspace.team_api_token
}
