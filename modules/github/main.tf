resource "github_repository" "application" {
  name        = var.repository_name
  description = var.repository_description
  visibility  = "private"

  template {
    owner      = var.template_organisation
    repository = var.template_repository
  }
}

resource "github_actions_secret" "tf_api_token" {
  repository      = github_repository.application.name
  plaintext_value = var.terraform_cloud_access_token
  secret_name     = "TF_API_TOKEN"
}
resource "github_actions_variable" "tf_cloud_organization" {
  repository    = github_repository.application.name
  value         = var.terraform_cloud_organisation
  variable_name = "TF_CLOUD_ORGANIZATION"
}
resource "github_actions_variable" "tf_workspace" {
  repository    = github_repository.application.name
  value         = var.terraform_cloud_workspace_name
  variable_name = "TF_WORKSPACE"
}

terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

provider "github" {
  owner = var.repository_organisation
}