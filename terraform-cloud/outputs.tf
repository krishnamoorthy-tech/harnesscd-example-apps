# Terraform Cloud Outputs
# These outputs are exposed to Harness via the TerraformCloudRun step
# and can be referenced in Infrastructure Definitions using expressions like:
# <+provisioner.PROVISIONER_ID.OUTPUT_NAME>

output "namespace_name" {
  description = "Name of the created Kubernetes namespace"
  value       = kubernetes_namespace.app_namespace.metadata[0].name
}

output "namespace_uid" {
  description = "UID of the created Kubernetes namespace"
  value       = kubernetes_namespace.app_namespace.metadata[0].uid
}

output "environment_type" {
  description = "Environment type label applied to the namespace"
  value       = var.environment_type
}

output "quota_name" {
  description = "Name of the resource quota created for the namespace"
  value       = kubernetes_resource_quota.namespace_quota.metadata[0].name
}

output "quota_cpu_requests" {
  description = "CPU request quota for the namespace"
  value       = kubernetes_resource_quota.namespace_quota.spec[0].hard["requests.cpu"]
}

output "quota_memory_requests" {
  description = "Memory request quota for the namespace"
  value       = kubernetes_resource_quota.namespace_quota.spec[0].hard["requests.memory"]
}

output "limit_range_name" {
  description = "Name of the limit range created for the namespace"
  value       = kubernetes_limit_range.namespace_limits.metadata[0].name
}

output "provisioning_status" {
  description = "Status of the provisioning operation"
  value       = "success"
}
