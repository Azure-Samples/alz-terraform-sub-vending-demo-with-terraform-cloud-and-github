variable "repository_name" {
  type        = string
  description = "Repository Name"
}

variable "repository_description" {
  type        = string
  description = "Repository Description"
}

variable "repository_organisation" {
  type        = string
  description = "Organisation Name in GH"
}

variable "template_organisation" {
  type        = string
  description = "Organisation Template"
}

variable "template_repository" {
  type        = string
  description = "Repository Template"
}

variable "terraform_cloud_organisation" {
  type        = string
  description = "Terraform Cloud Organisation"
}

variable "terraform_cloud_workspace_name" {
  type        = string
  description = "Terraform Cloud Workspace Name"
}

variable "terraform_cloud_access_token" {
  type        = string
  description = "Terrafrom Cloud Access Token"
  sensitive   = true
}
