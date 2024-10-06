#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Change to the directory of the script
cd "$(dirname "$0")"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required commands
for cmd in kubectl helm; do
    if ! command_exists "$cmd"; then
        echo "Error: $cmd is not installed or not in PATH"
        exit 1
    fi
done

# Check if auth-check.sh exists before sourcing
if [ -f "./auth-check.sh" ]; then
    source "./auth-check.sh"
else
    echo "Warning: auth-check.sh not found. Skipping authentication check."
fi

# Create a dedicated namespace for Kiosk
kubectl create namespace kiosk --dry-run=client -o yaml | kubectl apply -f -

# Add the Helm repository
helm repo add devspace https://charts.devspace.sh/
helm repo update

# Install Kiosk using Helm v3
if ! helm install kiosk devspace/kiosk --namespace kiosk --atomic; then
    echo "Error: Kiosk installation failed"
    exit 1
fi

# Verify the Kiosk pod is running
kubectl get pod -n kiosk

# Wait for the pod to be ready
if ! kubectl wait --for=condition=ready pod -l app=kiosk -n kiosk --timeout=120s; then
    echo "Error: Kiosk pod did not become ready within the timeout period"
    exit 1
fi

# Display Kiosk version and status
helm status kiosk -n kiosk

echo "Kiosk installation completed successfully"