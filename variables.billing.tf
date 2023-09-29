variable "billing_account_type" {
  type        = string
  description = "The type of billing account, can be ea, mca or mpa"
  validation {
    condition     = can(regex("^(ea|mca|mpa)$", var.billing_account_type))
    error_message = "The billing account type must be either ea, mca or mpa"
  }
}

variable "billing_account_name" {
  type        = string
  description = "The name of the billing account for ea, mca or mpa"
}

variable "billing_enrollment_account_name" {
  type        = string
  description = "The name of the billing enrollment for ea"
  default     = null
}

variable "billing_profile_name" {
  type        = string
  description = "The name of the billing account for mca"
  default     = null
}

variable "billing_invoice_section_name" {
  type        = string
  description = "The name of the billing invoice section for mca"
  default     = null
}

variable "billing_customer_name" {
  type        = string
  description = "The name of the billing customer for mpa"
  default     = null
}
