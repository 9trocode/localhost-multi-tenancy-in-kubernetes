#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

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

# Check Capsule installation
echo "Checking Capsule installation..."
if ! kubectl get namespace capsule-system &>/dev/null; then
    echo "Error: Capsule namespace not found. Please install Capsule first."
    exit 1
fi

if ! kubectl get deployment -n capsule-system capsule-controller-manager &>/dev/null; then
    echo "Error: Capsule deployment not found. Please check Capsule installation."
    exit 1
fi

# Wait for Capsule webhook to be ready
echo "Waiting for Capsule webhook to be ready..."
if ! kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=capsule -n capsule-system --timeout=120s; then
    echo "Error: Capsule webhook did not become ready within the timeout period"
    exit 1
fi