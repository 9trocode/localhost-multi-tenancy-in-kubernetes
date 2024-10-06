#!/bin/bash

# Check if the current user has all permissions in all namespaces
kubectl auth can-i "*" "*" --all-namespaces

# Check if the current user has all permissions on namespaces
kubectl auth can-i "*" namespace

# Check if the current user has all permissions on clusterroles
kubectl auth can-i "*" clusterrole

# Check if the current user has all permissions on custom resource definitions (CRDs)
kubectl auth can-i "*" crd