# Terraform Cloud Variables for Kubernetes Authentication
# These variables should be configured as workspace variables in Terraform Cloud
# Sensitive variables (token, CA cert) should be marked as "Sensitive" in the workspace

# Kubernetes cluster authentication
variable "kubernetes_host" {
  description = "Kubernetes API server URL (e.g., https://your-cluster.example.com:6443)"
  type        = string
}

variable "kubernetes_token" {
  description = "Kubernetes service account token for authentication (can be file path or raw token)"
  type        = string
  sensitive   = true
}

variable "kubernetes_cluster_ca_certificate" {
  description = "CA certificate for the Kubernetes cluster (can be file path, base64-encoded, or raw PEM)"
  type        = string
  sensitive   = true
}

# Namespace configuration
variable "namespace_name" {
  description = "Name of the Kubernetes namespace to create"
  type        = string
  default     = "harness-tf-cloud"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace_name))
    error_message = "Namespace name must consist of lowercase alphanumeric characters or '-', and must start and end with an alphanumeric character."
  }
}

variable "environment_type" {
  description = "Environment label for the namespace (e.g., dev, qa, staging, prod)"
  type        = string
  default     = "test"

  validation {
    condition     = contains(["dev", "qa", "staging", "prod", "test"], var.environment_type)
    error_message = "Environment type must be one of: dev, qa, staging, prod, test."
  }
}
