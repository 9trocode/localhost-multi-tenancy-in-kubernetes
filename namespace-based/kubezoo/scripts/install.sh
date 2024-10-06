readonly LOCAL_UP_IMAGE_TAG="v0.2.0"
readonly LOCAL_ARCH=$(go env GOHOSTARCH)
readonly LOCAL_OS=$(go env GOHOSTOS)

# Change to the directory of the script
cd "$(dirname "$0")"

# Get the absolute path of the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the root directory (Localhost-Multi-tenancy-In-Kubernetes)
ZOO_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"

kubectl apply -f $ZOO_ROOT/_output/setup/quota.yaml

# echo "Loading image on $CLUSTER_NAME..."
docker pull kubezoo/kubezoo:"${LOCAL_UP_IMAGE_TAG}"
docker pull kubezoo/clusterresourcequota:"${LOCAL_UP_IMAGE_TAG}"
docker tag kubezoo/kubezoo:"${LOCAL_UP_IMAGE_TAG}" kubezoo/kubezoo:local-up
docker tag kubezoo/clusterresourcequota:"${LOCAL_UP_IMAGE_TAG}" kubezoo/clusterresourcequota:local-up