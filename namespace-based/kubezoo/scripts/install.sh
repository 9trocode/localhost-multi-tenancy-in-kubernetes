# Change to the directory of the script
cd "$(dirname "$0")"

# Get the absolute path of the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the root directory (Localhost-Multi-tenancy-In-Kubernetes)
ZOO_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"

kubectl apply -f $ZOO_ROOT/_output/setup/quota.yaml