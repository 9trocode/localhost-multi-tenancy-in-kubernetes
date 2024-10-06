echo "Export kubezoo server to 6443"
kubectl --context "kind-${CLUSTER_NAME}" port-forward svc/kubezoo 6443:6443 &

# Capture the PID of the background process
PORT_FORWARD_PID=$!

echo "Port-forwarding started in background with PID: $PORT_FORWARD_PID"

# Optional: Wait a few seconds to ensure the port-forwarding is established
sleep 5

# You can add a check to see if the port-forwarding is still running
if ps -p $PORT_FORWARD_PID > /dev/null
then
    echo "Port-forwarding is running."
else
    echo "Error: Port-forwarding failed to start or has stopped."
    exit 1
fi