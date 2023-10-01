variable "subscription_name" {
  type        = string
  description = "The name of the subscription"
}

variable "location" {
  type        = string
  description = "Default location of the resources"
  validation {
    condition     = can(regex("^(uksouth|ukwest|westeurope|northeurope|eastus|westus|eastus2|westus2|southcentralus|centralus|northcentralus|japaneast|japanwest|southeastasia|australiaeast|australiasoutheast|brazilsouth|southafricanorth|canadacentral|canadaeast|francecentral|koreacentral|koreasouth|uksouth|ukwest|westcentralus|westeurope|westus|westus2)$", var.location))
    error_message = "The location must be a valid Azure region"
  }
}

variable "subscription_offer" {
  type        = string
  description = "The offer type of the subscription, can be DevTest or Production"
  validation {
    condition     = can(regex("^(DevTest|Production)$", var.subscription_offer))
    error_message = "The subscription offer must be either DevTest or Production"
  }
}

variable "subscription_description" {
  type        = string
  description = "The description of the subscriptions purpose"
}

variable "subscription_management_group" {
  type        = string
  description = "The management group name to assign the subscription to"
}

variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
    primary  = bool
  }))
  description = "The resource groups to create in the subscription"
}

variable "subscription_owners" {
  type        = list(string)
  description = "The spns of the owners of the subscription"
}
