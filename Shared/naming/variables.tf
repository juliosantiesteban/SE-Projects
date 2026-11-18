variable "project" {
  type        = string
  description = "Short project name, e.g. sepf"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,19}$", var.project))
    error_message = "project must be 2-20 chars: lowercase letters, digits, hyphens, starting with a letter."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test or prod."
  }
}

variable "owner" {
  type        = string
  description = "Who owns the resources (name or team)"
}

variable "location" {
  type        = string
  default     = ""
  description = "Optional short region code, e.g. use2 or eus"
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to merge in"
}
