data "tfe_project" "users" {
  name         = var.project_name
  organization = var.organisation
}

resource "tfe_workspace" "user_workspace" {
  name         = var.workspace_name
  organization = var.organisation
  project_id   = data.tfe_project.users.id
  force_delete = true
}

resource "tfe_team" "subscription_team" {
  name         = var.workspace_name
  organization = var.organisation
}
resource "tfe_team_access" "ws_access" {
  access       = var.team_access
  team_id      = tfe_team.subscription_team.id
  workspace_id = tfe_workspace.user_workspace.id
}

resource "tfe_team_token" "sub_team_token" {
  team_id = tfe_team.subscription_team.id
}

resource "tfe_variable" "arm_subscription_id" {
  key          = "ARM_SUBSCRIPTION_ID"
  value        = var.arm_subscription_id
  category     = "env"
  sensitive    = false
  workspace_id = tfe_workspace.user_workspace.id
  description  = "a useful description"
}

resource "tfe_variable" "arm_tenant_id" {
  key          = "ARM_TENANT_ID"
  value        = var.arm_tenant_id
  category     = "env"
  sensitive    = false
  workspace_id = tfe_workspace.user_workspace.id
  description  = "a useful description"
}

resource "tfe_variable" "azure_provider_auth" {
  key          = "TFC_AZURE_PROVIDER_AUTH"
  value        = "true"
  category     = "env"
  workspace_id = tfe_workspace.user_workspace.id
  description  = "a useful description"
}

resource "tfe_variable" "tfc_azure_run_client_id" {
  key          = "TFC_AZURE_RUN_CLIENT_ID"
  value        = var.tfc_azure_run_client_id
  category     = "env"
  sensitive    = false
  workspace_id = tfe_workspace.user_workspace.id
  description  = "a useful description"
}
