# Day 50 — Kubernetes Architecture & Cluster Setup

---

## Concept: Why Kubernetes?

Docker runs containers on one machine. But in production you have 100s of containers across multiple servers. You need something to:

- Automatically start/stop containers
- Handle failures (restart crashed containers)
- Distribute load across servers
- Scale up/down based on traffic

That's **Kubernetes (K8s)** — a container orchestrator created by Google, inspired by their internal system called Borg.

The name **Kubernetes** is Greek for **"helmsman/pilot"**.

---

## Task 2: Kubernetes Architecture

    ┌─────────────────────────────────────────────┐
    │            CONTROL PLANE (Master)           │
    │                                             │
    │  API Server  ←── all kubectl commands       │
    │  etcd        ←── cluster state database     │
    │  Scheduler   ←── decides which node to use  │
    │  Controller  ←── watches & fixes state      │
    └─────────────────────────────────────────────┘
                         ↕ communicates
    ┌──────────────────┐        ┌──────────────────┐
    │   Worker Node 1  │        │   Worker Node 2  │
    │  kubelet         │        │  kubelet         │
    │  kube-proxy      │        │  kube-proxy      │
    │  containerd      │        │  containerd      │
    │  [ Pod ] [ Pod ] │        │  [ Pod ] [ Pod ] │
    └──────────────────┘        └──────────────────┘

### What happens when you run `kubectl apply -f pod.yaml`?

1. `kubectl` sends a request to the **API Server**
2. API Server saves the desired state in **etcd**
3. **Scheduler** picks which node to place the pod on
4. **kubelet** on that node pulls the image and starts the container

---

## Task 3: Install kubectl

### macOS

    brew install kubectl
    kubectl version --client

### Linux (EC2)

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    kubectl version --client

---

## Task 4: Setup Local Cluster

### Option A — kind (Kubernetes in Docker)

#### Install on macOS

    brew install kind

#### Install on Linux

    curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind

#### Create Cluster

    kind create cluster --name devops-cluster

#### Verify

    kubectl cluster-info
    kubectl get nodes

### Option B — minikube

#### Install on macOS

    brew install minikube

#### Start

    minikube start

#### Verify

    kubectl cluster-info
    kubectl get nodes

> **For EC2 (Linux):** You already have **k3s** installed — that's even better because it is a lightweight full Kubernetes distribution.

---

## Task 5: Explore Your Cluster

### Cluster Endpoint Information

    kubectl cluster-info

### List All Nodes

    kubectl get nodes

### List Nodes with Details

    kubectl get nodes -o wide

### Describe a Node

    kubectl describe node NODE_NAME

### List Namespaces

    kubectl get namespaces

### List Pods in All Namespaces

    kubectl get pods -A

### List System Pods

    kubectl get pods -n kube-system

---

## Common kube-system Pods

| Pod | What it does |
|---|---|
| `etcd` | Cluster state database |
| `kube-apiserver` | Front door — handles all API calls |
| `kube-scheduler` | Assigns pods to nodes |
| `kube-controller-manager` | Watches & maintains desired state |
| `coredns` | DNS for pods inside cluster |
| `kube-proxy` | Networking rules on each node |

---

## Task 6: Cluster Lifecycle + kubeconfig

### Delete Cluster

#### kind

    kind delete cluster --name devops-cluster

#### minikube

    minikube delete

### Recreate Cluster

    kind create cluster --name devops-cluster
    kubectl get nodes

### Which Cluster Am I Connected To?

    kubectl config current-context

### List All Clusters / Contexts

    kubectl config get-contexts

### View Full kubeconfig

    kubectl config view

---

## What is kubeconfig?

`kubeconfig` is a configuration file used by `kubectl` to connect to a Kubernetes cluster.

It is usually located at:

    ~/.kube/config

It stores:

- Cluster address
- Authentication credentials
- Contexts
- Cluster connection information

### View kubeconfig

    cat ~/.kube/config

---

## Summary: Day 50 Key Points

| Concept | One Line |
|---|---|
| **Kubernetes** | Orchestrates containers at scale |
| **Control Plane** | Brain — API Server, etcd, Scheduler, Controller |
| **Worker Node** | Runs containers — kubelet, kube-proxy, runtime |
| **kubectl** | CLI to talk to the cluster |
| **kubeconfig** | `~/.kube/config` — stores cluster connection information |
| **kind / minikube** | Local Kubernetes cluster tools for practice |
| **k3s** | Lightweight Kubernetes distribution, useful for EC2 and low-resource environments |

---

## Key Concept

> **Kubernetes is declarative:** You tell Kubernetes **WHAT** you want, and Kubernetes figures out **HOW** to make it happen.

    You
     │
     │  kubectl apply -f pod.yaml
     ↓
    API Server
     │
     ↓
    etcd
     │
     ↓
    Scheduler
     │
     ↓
    Worker Node
     │
     ↓
    kubelet
     │
     ↓
    Container Runtime
     │
     ↓
    Pod

---

## Useful Commands Cheat Sheet

### Cluster Information

    kubectl cluster-info

### View Nodes

    kubectl get nodes
    kubectl get nodes -o wide

### Node Details

    kubectl describe node NODE_NAME

### Namespaces

    kubectl get namespaces

### All Pods

    kubectl get pods -A

### System Pods

    kubectl get pods -n kube-system

### Current Context

    kubectl config current-context

### List Contexts

    kubectl config get-contexts

### View kubeconfig

    kubectl config view

### Check kubectl Version

    kubectl version --client

---

## Kubernetes Architecture Components

### Control Plane

| Component | Responsibility |
|---|---|
| **API Server** | Entry point for all Kubernetes API requests |
| **etcd** | Stores complete cluster state |
| **Scheduler** | Assigns pods to suitable worker nodes |
| **Controller Manager** | Watches and maintains desired state |

### Worker Node

| Component | Responsibility |
|---|---|
| **kubelet** | Manages pods and containers on the node |
| **kube-proxy** | Handles service networking |
| **containerd** | Runs containers |
| **Pods** | Run application workloads |

---

## Kubernetes Request Flow

When you execute:

    kubectl apply -f pod.yaml

The flow is:

    kubectl
       ↓
    API Server
       ↓
    etcd
       ↓
    Scheduler
       ↓
    Worker Node
       ↓
    kubelet
       ↓
    containerd
       ↓
    Pod

---

## kind vs minikube vs k3s

| Tool | Purpose |
|---|---|
| **kind** | Runs Kubernetes clusters using Docker |
| **minikube** | Runs a local Kubernetes cluster for learning |
| **k3s** | Lightweight Kubernetes distribution |
| **kubectl** | CLI used to communicate with Kubernetes |

---

## Day 50 Practice Checklist

- [ ] Understand why Kubernetes is needed
- [ ] Understand Kubernetes architecture
- [ ] Understand Control Plane components
- [ ] Understand Worker Node components
- [ ] Install `kubectl`
- [ ] Create a cluster using kind
- [ ] Create a cluster using minikube
- [ ] Explore an existing k3s cluster
- [ ] Check nodes
- [ ] Check namespaces
- [ ] Check system pods
- [ ] Understand kubeconfig
- [ ] Check current Kubernetes context
- [ ] Practice basic `kubectl` commands

---

## Day 50 Complete

### Topics Covered

- Kubernetes fundamentals
- Kubernetes architecture
- Control Plane
- Worker Nodes
- API Server
- etcd
- Scheduler
- Controller Manager
- kubelet
- kube-proxy
- containerd
- kubectl
- kind
- minikube
- k3s
- Kubernetes cluster setup
- Cluster lifecycle
- Namespaces
- kubeconfig
- Kubernetes contexts
- Cluster exploration

---

## Final Takeaway

**Kubernetes manages containers at scale.**

The most important concept to remember:

> **You tell Kubernetes WHAT you want, and Kubernetes continuously works to make the actual state match the desired state.**

This declarative and self-healing approach is one of the core reasons Kubernetes is widely used for modern DevOps and cloud-native deployments.
