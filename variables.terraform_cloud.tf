variable "tfe_organisation_name" {
  type        = string
  description = "The Terraform Cloud Organisation to create the workspace in."
}

variable "tfe_project" {
  type        = string
  description = "The Terraform Cloud Organisation to create the workspace in."
}

variable "tfe_team_access" {
  type        = string
  description = "The default access level for the Terraform Cloud Team that is created."
  default     = "write"
}
