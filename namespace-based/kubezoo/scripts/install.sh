# Change to the directory of the script
cd "$(dirname "$0")"


ZOO_ROOT="$(pwd)/"

kubectl apply -f $ZOO_ROOT/_output/cluster-resource.yaml
