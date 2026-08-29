# Terraform Configuration for Harness Dynamic Provisioning

This directory contains Terraform configuration for provisioning Kubernetes namespaces with resource quotas and limits.

## Files

- `main.tf` - Main Terraform configuration (namespace, quota, limits)
- `outputs.tf` - Output definitions (13 outputs available)
- `variables.tf` - Variable definitions with validation
- `terraform.tfvars` - Default variable values

## Resources Created

1. **Kubernetes Namespace** with labels and annotations
2. **Resource Quota**:
   - CPU requests: 4 cores
   - Memory requests: 8Gi
   - CPU limits: 8 cores
   - Memory limits: 16Gi
   - Max pods: 20

3. **Limit Range**:
   - Container default: 500m CPU, 512Mi memory
   - Container default requests: 100m CPU, 128Mi memory
   - Container max: 2 CPU, 4Gi memory
   - Pod max: 4 CPU, 8Gi memory

## Outputs

13 outputs available for use in Harness pipelines:

1. `namespace_name` - Created namespace name
2. `namespace_uid` - Namespace unique ID
3. `namespace_labels` - All labels
4. `namespace_annotations` - All annotations
5. `environment_type` - Environment type
6. `quota_name` - Resource quota name
7. `quota_cpu_requests` - CPU requests quota
8. `quota_memory_requests` - Memory requests quota
9. `quota_cpu_limits` - CPU limits quota
10. `quota_memory_limits` - Memory limits quota
11. `quota_pod_limit` - Max pods
12. `limit_range_name` - Limit range name
13. `provisioning_status` - Status message

## Usage in Harness

### Pipeline Configuration

```yaml
configFiles:
  store:
    type: Github
    spec:
      connectorRef: GitHub_Connector
      gitFetchType: Branch
      branch: main
      folderPath: terraform
      repoName: KrishnamoorthyCDModule
```

### Variable Files

```yaml
varFiles:
  - varFile:
      type: Inline
      identifier: namespace_vars
      spec:
        content: |
          namespace_name   = "my-namespace"
          environment_type = "dev"
```

### Accessing Outputs

```yaml
<+pipeline.stages.STAGE.spec.provisioner.steps.TERRAFORM_APPLY.output.namespace_name>
<+pipeline.stages.STAGE.spec.provisioner.steps.TERRAFORM_APPLY.output.quota_cpu_requests>
```

## Requirements

- Terraform >= 1.0
- Kubernetes provider ~> 2.23
- Kubernetes cluster access (via Harness delegate)

## Testing Locally

```bash
cd terraform

# Initialize Terraform
terraform init

# Plan with custom values
terraform plan -var="namespace_name=test-ns" -var="environment_type=dev"

# Apply
terraform apply -auto-approve

# View outputs
terraform output

# Destroy
terraform destroy -auto-approve
```

## Notes

- Namespace names must be lowercase alphanumeric with hyphens
- Environment type must be: dev, qa, staging, or prod
- Kubernetes provider uses Harness delegate's kubeconfig
- All resources tagged with `managed-by: harness`
