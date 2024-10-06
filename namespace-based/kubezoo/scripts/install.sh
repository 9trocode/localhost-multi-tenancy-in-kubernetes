# Change to the directory of the script
cd "$(dirname "$0")"


# Get the absolute path of the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the parent directory of the script's directory
ZOO_ROOT="$(dirname "$SCRIPT_DIR")"

kubectl apply -f $ZOO_ROOT/_output/quota.yaml
