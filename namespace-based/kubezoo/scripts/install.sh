# Change to the directory of the script
cd "$(dirname "$0")"

kubectl apply -f cluster-resource.yaml
kubectl apply -f virtual-control-plane.yaml