#!/bin/bash
# Set strict mode
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    echo "Running test: $test_name"
    TESTS_RUN=$((TESTS_RUN + 1))
    # Run the command
    if eval "$test_command"; then
        echo -e "${GREEN}Test passed${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}Test failed${NC}"
        echo "Command: $test_command"
        return 1
    fi
}

# Function to wait for a condition with timeout
wait_for() {
    local command="$1"
    local condition="$2"
    local timeout="$3"
    local interval=10
    local timer=0
    while ! eval "$command" | grep -q "$condition"; do
        sleep $interval
        timer=$((timer + interval))
        echo -e "${YELLOW}Waiting for condition (${timer}s / ${timeout}s)${NC}"
        if [ $timer -ge $timeout ]; then
            echo "Timeout waiting for condition: $condition"
            return 1
        fi
    done
}

# Create a temporary directory for vcluster operations
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory for vcluster operations: $TEMP_DIR"

# vcluster name and namespace
VCLUSTER_NAME="test-vcluster"
VCLUSTER_NAMESPACE="vcluster-test"

# Create namespace for vcluster
if ! run_test "Create namespace for vcluster" \
    "kubectl create namespace ${VCLUSTER_NAMESPACE}"; then
    echo "Failed to create namespace. Exiting."
    exit 1
fi

# Install vcluster with increased timeout
if ! run_test "Install vcluster" \
    "cd $TEMP_DIR && vcluster create ${VCLUSTER_NAME} -n ${VCLUSTER_NAMESPACE} --connect=false --timeout 10m"; then
    echo "Failed to create vcluster. Exiting."
    exit 1
fi

# Wait for vcluster to be ready
if ! run_test "Wait for vcluster to be ready" \
    "wait_for 'kubectl get pods -n ${VCLUSTER_NAMESPACE}' 'vcluster.*Running' 600"; then
    echo "vcluster failed to become ready. Exiting."
    exit 1
fi

# Connect to vcluster
if ! run_test "Connect to vcluster" \
    "cd $TEMP_DIR && vcluster connect ${VCLUSTER_NAME} -n ${VCLUSTER_NAMESPACE} --server=https://127.0.0.1:8443 -- kubectl get nodes"; then
    echo "Failed to connect to vcluster. Exiting."
    exit 1
fi

# Create a test deployment in vcluster
if ! run_test "Create test deployment in vcluster" \
    "cd $TEMP_DIR && vcluster connect ${VCLUSTER_NAME} -n ${VCLUSTER_NAMESPACE} --server=https://127.0.0.1:8443 -- kubectl create deployment nginx --image=nginx"; then
    echo "Failed to create test deployment. Exiting."
    exit 1
fi

# Wait for the deployment to be ready
if ! run_test "Wait for deployment to be ready" \
    "cd $TEMP_DIR && vcluster connect ${VCLUSTER_NAME} -n ${VCLUSTER_NAMESPACE} --server=https://127.0.0.1:8443 -- kubectl wait --for=condition=available --timeout=120s deployment/nginx"; then
    echo "Deployment failed to become ready. Exiting."
    exit 1
fi

# Clean up
echo "Cleaning up resources..."
cd $TEMP_DIR && vcluster delete ${VCLUSTER_NAME} -n ${VCLUSTER_NAMESPACE}
kubectl delete namespace ${VCLUSTER_NAMESPACE}

# Remove the temporary directory
rm -rf $TEMP_DIR
echo "Removed temporary directory: $TEMP_DIR"

# Print test summary
echo "Tests run: $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
if [ $TESTS_RUN -eq $TESTS_PASSED ]; then
    echo -e "${GREEN}All tests passed!${NC}"
else
    echo -e "${RED}Some tests failed.${NC}"
fi