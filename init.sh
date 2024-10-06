# !/usr/bin/env bash

set -euo pipefail

ZOO_ROOT="$(pwd)/_output"
# source "lib/init.sh"

readonly REQUIRED_CMD=(
    go
    docker
    kubectl
    kind
)

readonly CLUSTER_NAME="localhost-e2e-test"
readonly KIND_KUBECONFIG=${KIND_KUBECONFIG:-${HOME}/.kube/config}

force_cleanup() {
    kind delete clusters "${CLUSTER_NAME}"
    rm -rf $ZOO_ROOT/_output
    exit 0
}

cleanup() {
    kind delete clusters "${CLUSTER_NAME}"
    rm -rf $ZOO_ROOT/_output
}

cleanup_on_err() {
    if [[ $? -ne 0 ]]; then
        cleanup
    fi
}

preflight() {
    echo "Preflight Check..."
    for bin in "${REQUIRED_CMD[@]}"; do
        command -v ${bin} >/dev/null 2>&1 || (echo "$bin is not installed" && exit 0)
    done
}

local_cluster() {
    echo "Creating the kind cluster $CLUSTER_NAME..."
    if kind get clusters | grep "${CLUSTER_NAME}"; then
        # cleanup && kind create cluster --name "${CLUSTER_NAME}"
        continue
    else
        kind create cluster --name "${CLUSTER_NAME}"
    fi
    kubectl config use-context "kind-${CLUSTER_NAME}"

    echo "Generating PKI and context..."
    bash lib/gen_pki.sh gen_pki_setup_ctx

    kubectl get nodes

    bash ./namespace-based/setup.sh

    bash ./virtual-multi-cluster/setup.sh



    # how to use the context
    # kubectl --context "kind-${CLUSTER_NAME}" port-forward svc/kubezoo 6443:6443

}

install_k3s() {
    log "Installing K3s..."
    curl -sfL https://get.k3s.io | sh -
    sudo chmod 644 /etc/rancher/k3s/k3s.yaml
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    success "K3s installed successfully"
}

wait_for_k3s() {
    log "Waiting for K3s to be ready..."
    while ! kubectl get nodes | grep -q "Ready"; do
        sleep 5
    done
    success "K3s is ready"
}

e2e() {
    bash ./namespace-based/e2e.sh
    bash ./virtual-multi-cluster/e2e.sh
}

preflight
