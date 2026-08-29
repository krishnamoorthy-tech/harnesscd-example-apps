# Terraform variable definitions

variable "namespace_name" {
  description = "Name of the Kubernetes namespace to create"
  type        = string
  default     = "harness-demo"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace_name))
    error_message = "Namespace name must consist of lowercase alphanumeric characters or '-', and must start and end with an alphanumeric character."
  }
}

variable "environment_type" {
  description = "Environment type (dev/qa/prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "qa", "staging", "prod"], var.environment_type)
    error_message = "Environment type must be one of: dev, qa, staging, prod."
  }
}
