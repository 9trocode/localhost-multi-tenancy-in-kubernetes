#!/bin/bash
# Set strict mode
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
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
    fi
}

# Function to wait for a condition with timeout
wait_for() {
    local command="$1"
    local condition="$2"
    local timeout="$3"
    local interval=5
    local timer=0
    while ! eval "$command" | grep -q "$condition"; do
        sleep $interval
        timer=$((timer + interval))
        if [ $timer -ge $timeout ]; then
            echo "Timeout waiting for condition: $condition"
            return 1
        fi
    done
}

# vcluster name and namespace
VCLUSTER_NAME="test-vcluster"
VCLUSTER_NAMESPACE="vcluster-test"

# Create namespace for vcluster
run_test "Create namespace for vcluster" \
    "kubectl create namespace ${VCLUSTER_NAMESPACE}"

# Install vcluster
run_test "Install vcluster" \
    "curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" && install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster"
    "vcluster create ${VCLUSTER_NAME} -n ${VCLUSTER_NAMESPACE}"

# Wait for vcluster to be ready
run_test "Wait for vcluster to be ready" \
    "wait_for 'kubectl get pods -n ${VCLUSTER_NAMESPACE}' 'Running' 300"

# Connect to vcluster
run_test "Connect to vcluster" \
    "vcluster connect ${VCLUSTER_NAME} -n ${VCLUSTER_NAMESPACE} -- kubectl get nodes"

# Create a test deployment in vcluster
run_test "Create test deployment in vcluster" \
    "vcluster connect ${VCLUSTER_NAME} -n ${VCLUSTER_NAMESPACE} -- kubectl create deployment nginx --image=nginx"

# Wait for the deployment to be ready
run_test "Wait for deployment to be ready" \
    "vcluster connect ${VCLUSTER_NAME} -n ${VCLUSTER_NAMESPACE} -- kubectl wait --for=condition=available --timeout=60s deployment/nginx"

# Clean up
echo "Cleaning up resources..."
vcluster delete ${VCLUSTER_NAME} -n ${VCLUSTER_NAMESPACE}
kubectl delete namespace ${VCLUSTER_NAMESPACE}

# Print test summary
echo "Tests run: $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
if [ $TESTS_RUN -eq $TESTS_PASSED ]; then
    echo -e "${GREEN}All tests passed!${NC}"
else
    echo -e "${RED}Some tests failed.${NC}"
fi