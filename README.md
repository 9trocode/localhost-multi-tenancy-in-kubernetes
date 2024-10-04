# Localhost Multi-Tenancy in Kubernetes

This repository demonstrates different approaches to achieving multi-tenancy in Kubernetes. Below is an overview of the directories and their purposes:

## namespace-based/
This folder contains various strategies for implementing multi-tenancy based on namespaces.

### capsule/
- Focuses on Capsule, which provides soft multi-tenancy, allowing tenant creation, user assignment, and isolation enforcement.

### kiosk/
- Contains Kiosk resources for namespace isolation.

### kubezoo/
- Resources related to the KubeZoo multi-tenancy platform.


## virtual-multi-cluster/ 
This folder contains resources for implementing virtual clusters and multi-cluster setups in Kubernetes to achieve hard multi-tenancy.

### capsule-proxy/
Implements Capsule proxy in virtual clusters to manage multi-tenant environments effectively.

##### gardener/
Provides resources and configurations for managing multi-tenancy using Gardener, a solution for managing Kubernetes clusters across multiple cloud providers.

### kamaji/
Multi-tenancy solutions using Kamaji to manage lightweight Kubernetes control planes.

### vCluster/
Resources to create and manage virtual clusters using `vCluster`, providing isolated Kubernetes environments for tenants.

---

Feel free to adjust the descriptions or add more details depending on the content of the files.