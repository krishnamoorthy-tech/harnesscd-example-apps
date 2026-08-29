# Terraform Cloud Configuration for Harness CD

This directory contains Terraform configuration files for provisioning Kubernetes namespaces via **Terraform Cloud** remote execution, integrated with **Harness Continuous Delivery**.

## Overview

This configuration provisions:
- **Kubernetes namespace** with labels and annotations
- **Resource quotas** to limit CPU, memory, and pod count
- **Limit ranges** to set default resource limits for containers

Key difference from `../terraform/`:
- Uses **explicit Kubernetes authentication** (host, token, CA certificate)
- Designed for **Terraform Cloud remote runners** (not local delegate execution)
- Requires workspace variables configured in Terraform Cloud

---

## Prerequisites

1. **Terraform Cloud Account**: Active account at https://app.terraform.io
2. **Terraform Cloud Workspace**: Create a workspace connected to this repository
3. **Kubernetes Cluster**: Accessible from Terraform Cloud remote runners (public or via Terraform Cloud Agents)
4. **Kubernetes Service Account**: With permissions to create namespaces, resource quotas, and limit ranges
5. **Harness Terraform Cloud Connector**: Configured with API token

---

## Terraform Cloud Workspace Configuration

### 1. Create Workspace

1. Go to https://app.terraform.io
2. Create a new workspace
3. Select "Version control workflow"
4. Connect to your GitHub repository
5. Set **Terraform Working Directory**: `terraform-cloud`

### 2. Configure Workspace Variables

Set the following variables in your Terraform Cloud workspace:

| Variable | Value | Sensitive | Description |
|----------|-------|-----------|-------------|
| `kubernetes_host` | `https://YOUR-CLUSTER-API:6443` | No | Kubernetes API server URL |
| `kubernetes_token` | `<service-account-token>` | **Yes** | Kubernetes service account token |
| `kubernetes_cluster_ca_certificate` | `<base64-encoded-CA>` | **Yes** | Base64-encoded CA certificate |
| `namespace_name` | `harness-tf-cloud` | No | Namespace to create |
| `environment_type` | `test` | No | Environment label (dev/qa/staging/prod/test) |

### 3. Get Kubernetes Credentials

#### For EKS (AWS):
```bash
# Get cluster endpoint
aws eks describe-cluster --name YOUR-CLUSTER --query "cluster.endpoint" --output text

# Get CA certificate
aws eks describe-cluster --name YOUR-CLUSTER --query "cluster.certificateAuthority.data" --output text

# Create service account and get token
kubectl create serviceaccount terraform-cloud -n kube-system
kubectl create clusterrolebinding terraform-cloud --clusterrole=cluster-admin --serviceaccount=kube-system:terraform-cloud
kubectl create token terraform-cloud -n kube-system --duration=87600h
```

#### For GKE (Google Cloud):
```bash
# Get cluster endpoint
gcloud container clusters describe YOUR-CLUSTER --zone YOUR-ZONE --format="get(endpoint)"

# Get CA certificate
gcloud container clusters describe YOUR-CLUSTER --zone YOUR-ZONE --format="get(masterAuth.clusterCaCertificate)"

# Create service account and get token
kubectl create serviceaccount terraform-cloud -n kube-system
kubectl create clusterrolebinding terraform-cloud --clusterrole=cluster-admin --serviceaccount=kube-system:terraform-cloud
kubectl create token terraform-cloud -n kube-system --duration=87600h
```

#### For AKS (Azure):
```bash
# Get cluster credentials
az aks get-credentials --resource-group YOUR-RG --name YOUR-CLUSTER

# Get cluster endpoint
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'

# Get CA certificate
kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}'

# Create service account and get token
kubectl create serviceaccount terraform-cloud -n kube-system
kubectl create clusterrolebinding terraform-cloud --clusterrole=cluster-admin --serviceaccount=kube-system:terraform-cloud
kubectl create token terraform-cloud -n kube-system --duration=87600h
```

---

## Harness Pipeline Integration

### Dynamic Provisioning Example

Use the **TerraformCloudRun** step in the **Environment > provisioner** section:

```yaml
provisioner:
  steps:
    # Step 1: Terraform Cloud Run - Plan
    - step:
        type: TerraformCloudRun
        name: Plan Namespace
        identifier: Plan_Namespace
        spec:
          provisionerIdentifier: tfc_k8s_namespace
          connectorRef: account.TerraformCloud
          organization: HarnessTesting
          workspace: harnesscd-example-apps
          runType: Plan
          spec:
            planType: Apply
            variables:
              - name: namespace_name
                value: <+pipeline.variables.namespace_name>
                valueType: string
              - name: environment_type
                value: <+pipeline.variables.environment_type>
                valueType: string
            discardPendingRuns: true
          runMessage: "Harness Pipeline: Plan for namespace provisioning"
        timeout: 10m
    
    # Step 2: Terraform Cloud Run - Apply
    - step:
        type: TerraformCloudRun
        name: Apply Namespace
        identifier: Apply_Namespace
        spec:
          provisionerIdentifier: tfc_k8s_namespace
          connectorRef: account.TerraformCloud
          organization: HarnessTesting
          workspace: harnesscd-example-apps
          runType: Apply
          spec: {}
          runMessage: "Harness Pipeline: Apply namespace provisioning"
        timeout: 10m

# Infrastructure Definition mapping
infrastructureDefinitions:
  - identifier: dynamic_k8s_infra
    inputs:
      type: KubernetesDirect
      spec:
        connectorRef: <+provisioner.tfc_k8s_namespace.connector_ref>
        namespace: <+provisioner.tfc_k8s_namespace.namespace_name>
        releaseName: release-<+INFRA_KEY_SHORT_ID>
```

### Ad Hoc Provisioning Example

Use the **TerraformCloudRun** step in the **Execution** section:

```yaml
execution:
  steps:
    # Terraform Cloud Run - PlanAndApply in one step
    - step:
        type: TerraformCloudRun
        name: Provision Namespace
        identifier: Provision_Namespace
        spec:
          provisionerIdentifier: tfc_namespace_adhoc
          connectorRef: account.TerraformCloud
          organization: HarnessTesting
          workspace: harnesscd-example-apps
          runType: PlanAndApply
          spec:
            variables:
              - name: namespace_name
                value: harness-adhoc
                valueType: string
              - name: environment_type
                value: dev
                valueType: string
          runMessage: "Harness Pipeline: Ad hoc namespace provisioning"
        timeout: 30m
```

---

## Outputs

The following outputs are available to Harness pipelines:

| Output | Description | Expression |
|--------|-------------|------------|
| `namespace_name` | Namespace name | `<+provisioner.PROVISIONER_ID.namespace_name>` |
| `namespace_uid` | Namespace UID | `<+provisioner.PROVISIONER_ID.namespace_uid>` |
| `environment_type` | Environment type | `<+provisioner.PROVISIONER_ID.environment_type>` |
| `quota_name` | Resource quota name | `<+provisioner.PROVISIONER_ID.quota_name>` |
| `quota_cpu_requests` | CPU quota | `<+provisioner.PROVISIONER_ID.quota_cpu_requests>` |
| `quota_memory_requests` | Memory quota | `<+provisioner.PROVISIONER_ID.quota_memory_requests>` |
| `limit_range_name` | Limit range name | `<+provisioner.PROVISIONER_ID.limit_range_name>` |
| `provisioning_status` | Status | `<+provisioner.PROVISIONER_ID.provisioning_status>` |

---

## Testing Locally

You can test this configuration locally before committing:

```bash
cd terraform-cloud

# Initialize Terraform
terraform init

# Set variables
export TF_VAR_kubernetes_host="https://YOUR-CLUSTER:6443"
export TF_VAR_kubernetes_token="YOUR-TOKEN"
export TF_VAR_kubernetes_cluster_ca_certificate="BASE64-CA-CERT"
export TF_VAR_namespace_name="test-namespace"
export TF_VAR_environment_type="dev"

# Plan
terraform plan

# Apply
terraform apply

# Verify
kubectl get namespace test-namespace
kubectl describe resourcequota -n test-namespace
kubectl describe limitrange -n test-namespace

# Cleanup
terraform destroy
```

---

## Troubleshooting

### Issue: "Unable to connect to Kubernetes API"

**Cause:** Terraform Cloud remote runners cannot reach your Kubernetes cluster.

**Solution:**
- Ensure your Kubernetes cluster API is publicly accessible, OR
- Use Terraform Cloud Agents to run Terraform in your private network, OR
- Use the `../terraform/` configuration with Harness delegates instead

### Issue: "Authentication failed"

**Cause:** Invalid or expired service account token.

**Solution:**
- Verify the token is valid: `kubectl --token="YOUR-TOKEN" get nodes`
- Regenerate token with longer duration: `kubectl create token terraform-cloud -n kube-system --duration=87600h`

### Issue: "Insufficient permissions"

**Cause:** Service account lacks required permissions.

**Solution:**
```bash
# Grant cluster-admin role (for testing)
kubectl create clusterrolebinding terraform-cloud \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:terraform-cloud

# Or create a custom role with minimal permissions
kubectl create role terraform-namespace-manager \
  --verb=create,get,list,update,delete \
  --resource=namespaces,resourcequotas,limitranges
```

### Issue: "Namespace already exists"

**Cause:** Previous run left the namespace.

**Solution:**
- Delete manually: `kubectl delete namespace NAMESPACE-NAME`
- Or use a different namespace name

---

## Comparison: Terraform Cloud vs. Delegate Execution

| Feature | Terraform Cloud (`terraform-cloud/`) | Delegate Execution (`terraform/`) |
|---------|--------------------------------------|-----------------------------------|
| Execution location | Terraform Cloud remote runners | Harness Delegate pods |
| Kubernetes auth | Explicit (token, CA cert) | Inherits from delegate's kubeconfig |
| State storage | Terraform Cloud | Harness (or skipped) |
| Plan file storage | Terraform Cloud | Delegate filesystem |
| Network access | Requires public cluster or TFC Agents | Works with private clusters |
| Setup complexity | Higher (workspace variables) | Lower (uses delegate context) |
| UI integration | Terraform Cloud UI + Harness | Harness only |
| Best for | Centralized Terraform management | Private/air-gapped environments |

---

## Next Steps

1. **Commit this directory** to your GitHub repository
2. **Configure Terraform Cloud workspace** with required variables
3. **Test a run** in Terraform Cloud UI to verify connectivity
4. **Create Harness pipeline** with TerraformCloudRun steps
5. **Map outputs** to Infrastructure Definition

For more information, see:
- [Terraform Cloud documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- [Harness Terraform Cloud integration](https://developer.harness.io/docs/continuous-delivery/cd-infrastructure/terraform-infra/terraform-cloud-deployments)
