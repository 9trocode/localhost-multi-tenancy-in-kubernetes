#!/bin/bash
set -e

# Get the absolute path of the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the root directory (Localhost-Multi-tenancy-In-Kubernetes)
ZOO_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"

# Path to the quota file
QUOTA_FILE="$ZOO_ROOT/_output/setup/quota.yaml"

# Check if the quota file exists
if [ ! -f "$QUOTA_FILE" ]; then
    echo "Error: quota.yaml not found at: $QUOTA_FILE"
    echo "Current directory: $(pwd)"
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    echo "ZOO_ROOT: $ZOO_ROOT"
    echo "Searching for quota.yaml in ZOO_ROOT:"
    find "$ZOO_ROOT" -name quota.yaml
    exit 1
fi

# Apply the quota file
echo "Applying quota from: $QUOTA_FILE"
kubectl apply -f "$QUOTA_FILE"

if [ $? -ne 0 ]; then
    echo "Error: Failed to apply quota.yaml"
    echo "kubectl version:"
    kubectl version
    echo "Current Kubernetes context:"
    kubectl config current-context
    exit 1
fi

echo "Quota applied successfully"