#!/bin/bash
# Set strict mode
set -euo pipefail

# Change to the directory of the script
cd "$(dirname "$0")"

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

# Example tests
run_test "Capsule Tenant profile" \
    "kubectl apply -f yaml/tenant-profile.yaml"

run_test "Capsule View Only" \
    "kubectl apply -f yaml/view-only-tenant.yaml"

run_test "Group of Tenants" \
    "kubectl apply -f yaml/group-of-tenant-profile.yaml"
    
run_test "Complete Tenants" \
    "kubectl apply -f yaml/complete-tenant.yaml"

# Clean up
echo "Cleaning up resources..."
kubectl delete -f yaml/tenant-profile.yaml
kubectl delete -f yaml/view-only-tenant.yaml
kubectl delete -f yaml/group-of-tenant-profile.yaml
kubectl delete -f yaml/complete-tenant.yaml

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