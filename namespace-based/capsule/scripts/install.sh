#!/bin/bash

set -eu

# Define variables
CAPSULE_NAMESPACE="capsule-system"
CAPSULE_VERSION="0.7.1"  # Change this to the version you want to install

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."
for cmd in kubectl helm; do
    if ! command_exists "$cmd"; then
        echo "Error: $cmd is not installed. Please install it and try again."
        exit 1
    fi
done

# Check if kubectl can connect to a cluster
if ! kubectl cluster-info &>/dev/null; then
    echo "Error: kubectl is not connected to a cluster. Please configure kubectl and try again."
    exit 1
fi

# Add the Capsule Helm repository
echo "Adding Capsule Helm repository..."
helm repo add capsule https://projectcapsule.github.io/charts
helm repo update

# Create namespace for Capsule
echo "Creating namespace: $CAPSULE_NAMESPACE"
kubectl create namespace "$CAPSULE_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Install Capsule
echo "Installing Capsule version $CAPSULE_VERSION..."
helm upgrade --install \
    capsule capsule/capsule \
    --namespace "$CAPSULE_NAMESPACE" \
    --version "$CAPSULE_VERSION" \
    --set manager.options.forceTenantPrefix=true

# Check if the installation was successful
if kubectl get pods -n "$CAPSULE_NAMESPACE" | grep -q "capsule-controller-manager"; then
    echo "Capsule has been successfully installed!"
else
    echo "Error: Capsule installation seems to have failed. Please check the logs."
    exit 1
fi

echo "Capsule installation complete. You can now start creating tenants and managing your multi-tenant cluster."