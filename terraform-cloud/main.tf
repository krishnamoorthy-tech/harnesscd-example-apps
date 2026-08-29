# Terraform Cloud Configuration for Harness CD Dynamic Provisioning
# This configuration provisions a Kubernetes namespace with resource quotas and limit ranges
# via Terraform Cloud remote execution.
#
# Key difference from terraform/main.tf:
# - This uses explicit Kubernetes authentication variables (host, token, CA cert)
# - Designed for Terraform Cloud remote runners
# - Requires workspace variables configured in Terraform Cloud

terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# Kubernetes provider configuration
# Authentication credentials are passed as workspace variables in Terraform Cloud
# When using TFC agents running in-cluster, the token and CA cert are read from files
provider "kubernetes" {
  host                   = var.kubernetes_host
  token                  = var.kubernetes_token
  cluster_ca_certificate = var.kubernetes_cluster_ca_certificate
}

# Create Kubernetes namespace with labels and annotations
resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = var.namespace_name

    labels = {
      environment = var.environment_type
      managed-by  = "harness"
      provisioner = "terraform-cloud"
      source      = "github"
    }

    annotations = {
      "harness.io/managed" = "true"
      "harness.io/source"  = "github-terraform-cloud"
    }
  }
}

# Resource quota to limit resource consumption in the namespace
resource "kubernetes_resource_quota" "namespace_quota" {
  metadata {
    name      = "${var.namespace_name}-quota"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = "4"
      "requests.memory" = "8Gi"
      "limits.cpu"      = "8"
      "limits.memory"   = "16Gi"
      "pods"            = "20"
    }
  }
}

# Limit range to set default resource limits for containers
resource "kubernetes_limit_range" "namespace_limits" {
  metadata {
    name      = "${var.namespace_name}-limits"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  spec {
    limit {
      type = "Container"

      default = {
        cpu    = "500m"
        memory = "512Mi"
      }

      default_request = {
        cpu    = "100m"
        memory = "128Mi"
      }

      max = {
        cpu    = "2"
        memory = "4Gi"
      }

      min = {
        cpu    = "50m"
        memory = "64Mi"
      }
    }

    limit {
      type = "Pod"

      max = {
        cpu    = "4"
        memory = "8Gi"
      }
    }
  }
}
