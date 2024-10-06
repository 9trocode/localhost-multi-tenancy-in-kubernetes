provider "helm" {
  kubernetes {
    # Path to the kubeconfig file used to authenticate to the Kubernetes cluster.
    # Adjust this path if your kubeconfig is in a different location.
    config_path = "~/.kube/config"
  }
}

# Helm Release for vcluster: Install a virtual cluster within an existing Kubernetes cluster
resource "helm_release" "my_vcluster" {
  # The name for the vcluster Helm release
  name             = "my-vcluster"
  
  # Namespace where the vcluster will be deployed. If the namespace does not exist,
  # it will be automatically created with the 'create_namespace' option.
  namespace        = "team-x"
  create_namespace = true

  # The repository URL containing the vcluster Helm chart.
  repository       = "https://charts.loft.sh"

  # The specific Helm chart to use for vcluster deployment.
  chart            = "vcluster"

  # Optional: Specify custom values for the vcluster configuration.
  # Ensure you have a 'vcluster.yaml' file with the appropriate configurations.
  # If no custom values are needed, you can remove the 'values' section.
  values = [
    file("${path.module}/vcluster.yaml")
  ]
}
