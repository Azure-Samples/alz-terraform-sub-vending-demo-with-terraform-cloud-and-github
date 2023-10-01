variable "workspace_name" {
  description = "workspace_name"
  type        = string
}
variable "organisation" {
  description = "organisation"
  type        = string
}
variable "team_access" {
  description = "team_access"
  type        = string
  default     = "write"
}
variable "arm_subscription_id" {
  description = "arm_subscription_id"
  type        = string
}
variable "arm_tenant_id" {
  description = "arm_tenant_id"
  type        = string
}
variable "tfc_azure_run_client_id" {
  description = "tfc_azure_run_client_id"
  type        = string
}
variable "project_name" {
  type = string
}
