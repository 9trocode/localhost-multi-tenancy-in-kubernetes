#!/bin/bash

# Create a dedicated namespace for Kiosk
kubectl create namespace kiosk

# Install Kiosk using Helm v3
# --repo: Specifies the Helm chart repository
# --atomic: Ensures the installation rolls back on failure
helm install kiosk --repo https://charts.devspace.sh/ kiosk --namespace kiosk --atomic

# Verify the Kiosk pod is running
kubectl get pod -n kiosk

# Optional: Wait for the pod to be ready
kubectl wait --for=condition=ready pod -l app=kiosk -n kiosk --timeout=60s

# Display Kiosk version and status
helm status kiosk -n kiosk