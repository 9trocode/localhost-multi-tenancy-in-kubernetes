#!/bin/bash
set -e

# Default values
RELEASE_NAME="my-vcluster"
NAMESPACE="vcluster"
CHART_VERSION="latest"
VALUES_FILES=(
    "./values.yaml"
)

# Function to display usage
usage() {
    echo "Usage: $0 [-n NAMESPACE] [-r RELEASE_NAME] [-v CHART_VERSION] [-f VALUES_FILE]..."
    echo "  -n NAMESPACE     Kubernetes namespace to install vcluster (default: vcluster)"
    echo "  -r RELEASE_NAME  Helm release name (default: my-vcluster)"
    echo "  -v CHART_VERSION vcluster Helm chart version (default: latest)"
    echo "  -f VALUES_FILE   Path to a values file for Helm (can be used multiple times)"
    exit 1
}

# Parse command line arguments
while getopts "n:r:v:f:h" opt; do
    case ${opt} in
        n ) NAMESPACE=$OPTARG ;;
        r ) RELEASE_NAME=$OPTARG ;;
        v ) CHART_VERSION=$OPTARG ;;
        f ) VALUES_FILES+=("$OPTARG") ;;
        h ) usage ;;
        \? ) usage ;;
    esac
done

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "Helm is not installed. Please install Helm and try again."
    exit 1
fi

# Add the vcluster Helm repository
echo "Adding vcluster Helm repository..."
helm repo add loft-sh https://charts.loft.sh
helm repo update

# Create namespace if it doesn't exist
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo "Creating namespace $NAMESPACE..."
    kubectl create namespace "$NAMESPACE"
fi


# Prepare the Helm install command
HELM_CMD="helm install $RELEASE_NAME loft-sh/vcluster --namespace $NAMESPACE"

# Add chart version if specified
if [ "$CHART_VERSION" != "latest" ]; then
    HELM_CMD="$HELM_CMD --version $CHART_VERSION"
fi

# Add values files to the command
# for values_file in "${VALUES_FILES[@]}"; do
#     if [ -f "$values_file" ]; then
#         HELM_CMD="$HELM_CMD -f $values_file"
#     else
#         echo "Error: Values file $values_file not found."
#         exit 1
#     fi
# done

# Install vcluster
echo "Installing vcluster with command:"
echo "$HELM_CMD"
echo "Proceeding with installation..."
eval $HELM_CMD

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "vcluster installed successfully!"
    echo "Release name: $RELEASE_NAME"
    echo "Namespace: $NAMESPACE"
    echo "Values files used:"
    for file in "${VALUES_FILES[@]}"; do
        echo "  - $file"
    done
else
    echo "Failed to install vcluster. Please check the error messages above."
    exit 1
fi