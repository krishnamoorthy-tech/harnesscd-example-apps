terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# Variables
variable "namespace_name" {
  description = "Name of the Kubernetes namespace to create"
  type        = string
  default     = "harness-demo"
}

variable "environment_type" {
  description = "Environment type (dev/qa/prod)"
  type        = string
  default     = "dev"
}

# Kubernetes provider - uses delegate's kubeconfig
provider "kubernetes" {
  # Harness delegate provides cluster access
}

# Create Kubernetes namespace
resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = var.namespace_name

    labels = {
      environment = var.environment_type
      managed-by  = "harness"
      provisioner = "terraform"
      source      = "github"
    }

    annotations = {
      "harness.io/managed" = "true"
      "harness.io/source"  = "github-terraform"
    }
  }
}

# Create resource quota for the namespace
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

# Create limit range for the namespace
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
