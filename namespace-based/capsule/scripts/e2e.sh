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
    local expected_output="$3"
    
    echo "Running test: $test_name"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    # Run the command and capture its output
    local actual_output
    if ! actual_output=$(eval "$test_command" 2>&1); then
        echo -e "${RED}Test failed: Command execution error${NC}"
        echo "Command: $test_command"
        echo "Error output: $actual_output"
        return 1
    fi
    
    # Compare the output
    if [[ "$actual_output" == *"$expected_output"* ]]; then
        echo -e "${GREEN}Test passed${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}Test failed${NC}"
        echo "Expected output to contain: $expected_output"
        echo "Actual output: $actual_output"
        return 1
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

# Example tests

# Test creating a namespace
run_test "Create namespace" \
    "kubectl create -f tenant-profile.yaml"
    
# # Test deploying a simple application
# run_test "Deploy nginx" \
#     "kubectl create deployment nginx --image=nginx -n test-namespace" \
#     "deployment.apps/nginx created"

# # Wait for the nginx pod to be ready
# wait_for "kubectl get pods -n test-namespace" "Running" 60

# # Test getting pods
# run_test "Get pods" \
#     "kubectl get pods -n test-namespace" \
#     "nginx"

# # Test creating a service
# run_test "Create service" \
#     "kubectl expose deployment nginx --port=80 --type=NodePort -n test-namespace" \
#     "service/nginx exposed"

# # Test getting services
# run_test "Get services" \
#     "kubectl get services -n test-namespace" \
#     "nginx"

# Clean up
kubectl delete namespace test-namespace

# Print test summary
echo "Tests run: $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"

if [ $TESTS_RUN -eq $TESTS_PASSED ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi