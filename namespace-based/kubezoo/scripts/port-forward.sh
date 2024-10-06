#!/bin/bash

echo "Waiting for kubezoo pod to be ready..."

# Function to check if the pod is ready
check_pod_ready() {
    kubectl --context "kind-${CLUSTER_NAME}" get pods -l app=kubezoo -o jsonpath='{.items[0].status.phase}' | grep "Running"
}

# Wait for the pod to be in Running state, with a timeout
TIMEOUT=300  # 5 minutes timeout
ELAPSED=0
while ! check_pod_ready; do
    if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "Timeout waiting for kubezoo pod to be ready"
        exit 1
    fi
    sleep 5
    ELAPSED=$((ELAPSED+5))
    echo "Still waiting for kubezoo pod to be ready... (${ELAPSED}s elapsed)"
done

echo "Kubezoo pod is ready. Starting port-forward..."

# Start port-forwarding in the background
kubectl --context "kind-${CLUSTER_NAME}" port-forward svc/kubezoo 6443:6443 &

# Capture the PID of the background process
PORT_FORWARD_PID=$!

echo "Port-forwarding started in background with PID: $PORT_FORWARD_PID"

# Wait a few seconds to ensure the port-forwarding is established
sleep 5

# Check if the port-forwarding is still running
if ps -p $PORT_FORWARD_PID > /dev/null
then
    echo "Port-forwarding is running successfully."
else
    echo "Error: Port-forwarding failed to start or has stopped."
    exit 1
fi

echo "Kubezoo server exported to port 6443"