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

variable "workspace_name" {
  type        = string
  description = "Workspace Name"
}

variable "access_token" {
  type        = string
  description = "Access Token"
  sensitive   = true
}
