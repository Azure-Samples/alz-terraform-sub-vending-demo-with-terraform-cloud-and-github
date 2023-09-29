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
  plaintext_value = var.access_token
  secret_name     = "TF_API_TOKEN"
}
resource "github_actions_secret" "tf_name" {
  repository      = github_repository.application.name
  plaintext_value = var.workspace_name
  secret_name     = "TF_NAME"
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