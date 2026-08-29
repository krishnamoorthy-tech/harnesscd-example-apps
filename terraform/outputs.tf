# Terraform outputs accessible in Harness pipeline

output "namespace_name" {
  description = "Name of the created Kubernetes namespace"
  value       = kubernetes_namespace.app_namespace.metadata[0].name
}

output "namespace_uid" {
  description = "Unique ID of the namespace"
  value       = kubernetes_namespace.app_namespace.metadata[0].uid
}

output "namespace_labels" {
  description = "Labels applied to the namespace"
  value       = kubernetes_namespace.app_namespace.metadata[0].labels
}

output "namespace_annotations" {
  description = "Annotations applied to the namespace"
  value       = kubernetes_namespace.app_namespace.metadata[0].annotations
}

output "environment_type" {
  description = "Environment type"
  value       = var.environment_type
}

output "quota_name" {
  description = "Name of the resource quota"
  value       = kubernetes_resource_quota.namespace_quota.metadata[0].name
}

output "quota_cpu_requests" {
  description = "CPU requests quota"
  value       = kubernetes_resource_quota.namespace_quota.spec[0].hard["requests.cpu"]
}

output "quota_memory_requests" {
  description = "Memory requests quota"
  value       = kubernetes_resource_quota.namespace_quota.spec[0].hard["requests.memory"]
}

output "quota_cpu_limits" {
  description = "CPU limits quota"
  value       = kubernetes_resource_quota.namespace_quota.spec[0].hard["limits.cpu"]
}

output "quota_memory_limits" {
  description = "Memory limits quota"
  value       = kubernetes_resource_quota.namespace_quota.spec[0].hard["limits.memory"]
}

output "quota_pod_limit" {
  description = "Maximum number of pods allowed"
  value       = kubernetes_resource_quota.namespace_quota.spec[0].hard["pods"]
}

output "limit_range_name" {
  description = "Name of the limit range"
  value       = kubernetes_limit_range.namespace_limits.metadata[0].name
}

output "provisioning_status" {
  description = "Status message"
  value       = "Terraform provisioning completed successfully for namespace: ${kubernetes_namespace.app_namespace.metadata[0].name}"
}
