locals {
  terraform_cloud_workspace_name      = "user-${var.subscription_name}"
  user_assigned_managed_identity_name = "umi-${var.subscription_name}"
  identity_resource_group_name        = "rg-identity"
  github_repository_name              = var.subscription_name
}

locals {
  subscription_user_owners = { for user in data.azuread_users.subscription_owners.users : user.object_id => {
    principal_id   = user.object_id
    definition     = "Owner"
    relative_scope = ""
    }
  }
}