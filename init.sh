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

e2e() {
    bash ./namespace-based/e2e.sh
    bash ./virtual-multi-cluster/e2e.sh
}

preflight
