#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

KAMAJI_VERSION="v0.3.0"  # Update this to the latest version as needed
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
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml
    
    log "Waiting for cert-manager to be ready..."
    kubectl wait --for=condition=Available deployment --all -n cert-manager --timeout=300s
    
    success "cert-manager installed successfully"
}

install_kamaji() {
    log "Installing Kamaji ${KAMAJI_VERSION}..."
    
    # Create kamaji-system namespace
    kubectl create namespace kamaji-system --dry-run=client -o yaml | kubectl apply -f -
    
    # Install Kamaji CRDs
    kubectl apply -f https://github.com/clastix/kamaji/releases/download/${KAMAJI_VERSION}/crds.yaml
    
    # Install Kamaji
    kubectl apply -f https://github.com/clastix/kamaji/releases/download/${KAMAJI_VERSION}/kamaji.yaml
    
    log "Waiting for Kamaji to be ready..."
    kubectl wait --for=condition=Available deployment --all -n kamaji-system --timeout=300s
    
    success "Kamaji installed successfully"
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