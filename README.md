# 🏴‍☠️ The Grand Line of Kubernetes Multi-Tenancy 🌊

Ahoy, future Pirate King of Kubernetes! Welcome aboard the Thousand Sunny of multi-tenancy. This repository demonstrates different approaches to achieving multi-tenancy in Kubernetes. Below is an overview of the directories and their purposes:

## 🗺️ Project Layout

### 🏝️ East Blue: namespace-based/

In these calm waters, we explore the basics of multi-tenancy:

- **Capsule**: Implements soft multi-tenancy, enabling secure tenant creation and isolation.
- **Kiosk**: Provides resources for effective namespace isolation.
- **KubeZoo**: Offers a platform for managing multi-tenant environments.

### 🌋 Grand Line: virtual-multi-cluster/

Discover advanced multi-tenancy with virtual and multi-cluster setups:

- **Capsule Proxy**: Enhances multi-tenant management in virtual cluster environments.
- **Gardener**: Manages Kubernetes clusters across multiple cloud providers.
- **Kamaji**: Implements lightweight Kubernetes control planes for multi-tenancy.
- **vCluster**: Creates and manages isolated virtual Kubernetes environments.

## 🧭 Setting Sail: Project Setup

### 📜 Devil Fruit Powers (Prerequisites)

Consume these to gain incredible abilities:
- `kind`: Shape reality (and clusters) at will
- `k3s`: Summon lightweight Kubernetes minions
- `helm`: Control the seas (and deployments) with charts
- `kubectl`: Command your fleet with a single word


### 🧙‍♂️ Magical Incantations (Environment Variables)

- `ZOO_ROOT`: The sacred ground of your project (`$(pwd)/_output`)
- `CLUSTER_NAME`: Your fleet's flagship (`"localhost-e2e-test"`)

## 🚀 Usage Guide

### 🏗️ Summon Your Fleet

To set up a Kubernetes cluster locally using `kind`, run:

```bash
make setup-cluster
```

To set up a Kubernetes cluster locally using `k3s`, run:

```bash
make install_k3s
```

This command sources `./init.sh` and runs the `install_k3s` function.

### Run E2E Tests

```bash
make e2e
```

This command sources `./init.sh` and runs the `cleanup` function.

### Cleanup

```bash
make cleanup
```

---