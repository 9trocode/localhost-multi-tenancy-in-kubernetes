#!/bin/bash
set -euo pipefail

# Change to the directory of the script
cd "$(dirname "$0")"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

KAMAJI_VERSION="v1.0.0"  # Update this to the latest version as needed
CERT_MANAGER_VERSION="v1.8.0"  # Update this to the latest version as needed

log() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1${NC}"
}

check_prerequisites() {
    log "Checking prerequisites..."
    if ! command -v kubectl &> /dev/null; then
        error "kubectl is not installed. Please install kubectl and try again."
        exit 1
    fi
    success "Prerequisites checked"
}

install_cert_manager() {
    log "Installing cert-manager..."
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.11.0 \
    --set installCRDs=true
    
    log "Waiting for cert-manager to be ready..."
    kubectl wait --for=condition=Available deployment --all -n cert-manager --timeout=300s
    
    success "cert-manager installed successfully"
}

install_kamaji() {
    log "Installing Kamaji from Helm repository..."
    helm repo add clastix https://clastix.github.io/charts
    helm repo update
    helm install kamaji clastix/kamaji -n kamaji-system --create-namespace --values values.yaml
    helm status kamaji -n kamaji-system
    success "Kamaji installed from Helm repository"
}


verify_installation() {
    log "Verifying Kamaji installation..."
    
    if kubectl get tenantcontrolplane -A &> /dev/null; then
        success "Kamaji installation verified"
    else
        error "Kamaji installation could not be verified. Please check the logs."
        exit 1
    fi
}

main() {
    log "Starting Kamaji installation"
    
    check_prerequisites
    install_cert_manager
    install_kamaji
    verify_installation
    
    log "Kamaji installation completed successfully"
}

main