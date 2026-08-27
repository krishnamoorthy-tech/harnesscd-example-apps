terraform {
  required_version = ">= 1.0"
  
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

variable "prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "harness-tg"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "test"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_id" "timestamp" {
  byte_length = 4
}

output "resource_id" {
  value       = "${var.prefix}-${var.environment}-${random_string.suffix.result}"
  description = "Generated resource identifier"
}

output "full_name" {
  value       = "${var.prefix}-${var.environment}-${random_string.suffix.result}-${random_id.timestamp.hex}"
  description = "Full resource name with timestamp"
}

output "environment" {
  value       = var.environment
  description = "Environment name"
}

# Dynamic infrastructure mapping outputs for Harness
output "connector_ref" {
  description = "Harness Kubernetes connector identifier for deployment"
  value       = "account.k8sconnector"  # Replace with your actual connector ID
}

output "namespace" {
  description = "Kubernetes namespace for deployment"
  value       = "terragrunt-test"  # Replace with your target namespace
}
