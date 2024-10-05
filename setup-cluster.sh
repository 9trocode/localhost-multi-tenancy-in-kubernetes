# !/usr/bin/env bash

set -eu

ZOO_ROOT="$(pwd)"
source "lib/init.sh"

readonly REQUIRED_CMD=(
    go
    docker
    kubectl
    kind
)

readonly CLUSTER_NAME="localhost-e2e-test"
readonly KIND_KUBECONFIG=${KIND_KUBECONFIG:-${HOME}/.kube/config}

cleanup() {
    rm -rf $ZOO_ROOT/_output
    if kind get clusters | grep "${CLUSTER_NAME}"; then
        kubectl --context "kind-${CLUSTER_NAME}" delete statefulset --all
        kubectl --context "kind-${CLUSTER_NAME}" delete deployment --all
        kubectl --context "kind-${CLUSTER_NAME}" delete validatingwebhookconfigurations --all
    fi
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
        cleanup
    else
        kind create cluster --name "${CLUSTER_NAME}"
    fi
    kubectl config use-context "kind-${CLUSTER_NAME}"

    echo "Generating PKI and context..."
    bash "${ZOO_ROOT}"/lib/gen_pki.sh gen_pki_setup_ctx



    how to use the context
    # kubectl --context "kind-${CLUSTER_NAME}" port-forward svc/kubezoo 6443:6443

}

preflight
local_cluster