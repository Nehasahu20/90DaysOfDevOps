# Day 50 — Kubernetes: Architecture & Introduction

## What is Kubernetes?

Kubernetes (K8s) is a container orchestration platform. It manages running containers at scale — starting, stopping, scaling, and healing them automatically.

### Without Kubernetes

You manually:
- Start containers
- Restart crashed containers
- Scale up/down
- Load balance

Problems:
- Does not scale
- Human error
- No self-healing

### With Kubernetes

You declare:

> "I want 3 copies of this app always running"

Kubernetes handles:
- Starting containers
- Restarting crashed containers
- Scaling applications
- Distributing load
- Maintaining the desired state

---

# Kubernetes Architecture

A Kubernetes cluster has two types of machines:

    ┌─────────────────────────────────────────────────────────────┐
    │                     KUBERNETES CLUSTER                     │
    │                                                             │
    │  ┌───────────────────────────────────────────────────────┐  │
    │  │                 CONTROL PLANE                        │  │
    │  │              (The Brain of K8s)                      │  │
    │  │                                                       │  │
    │  │  ┌──────────────┐       ┌─────────────────────────┐  │  │
    │  │  │  API Server  │       │          etcd           │  │  │
    │  │  │ (Front Door) │       │   (Cluster Database)    │  │  │
    │  │  └──────────────┘       └─────────────────────────┘  │  │
    │  │                                                       │  │
    │  │  ┌──────────────┐       ┌─────────────────────────┐  │  │
    │  │  │  Scheduler   │       │  Controller Manager     │  │  │
    │  │  │ (Assign Pods)│       │ (Watches & Fixes State) │  │  │
    │  │  └──────────────┘       └─────────────────────────┘  │  │
    │  └───────────────────────────────────────────────────────┘  │
    │                           │                                 │
    │          ┌────────────────┼────────────────┐                │
    │          │                │                │                │
    │  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐     │
    │  │ WORKER NODE   │ │ WORKER NODE   │ │ WORKER NODE   │     │
    │  │  (Runs Apps)  │ │  (Runs Apps)  │ │  (Runs Apps)  │     │
    │  │               │ │               │ │               │     │
    │  │   kubelet     │ │   kubelet     │ │   kubelet     │     │
    │  │   kube-proxy  │ │   kube-proxy  │ │   kube-proxy  │     │
    │  │   containerd  │ │   containerd  │ │   containerd  │     │
    │  │   [Pod][Pod]  │ │   [Pod][Pod]  │ │   [Pod][Pod]  │     │
    │  └───────────────┘ └───────────────┘ └───────────────┘     │
    └─────────────────────────────────────────────────────────────┘

---

# Control Plane Components

## 1. API Server (`kube-apiserver`)

The API Server is the entry point for all communication.

Every `kubectl` command talks to the API Server.

It:
- Provides a REST API
- Accepts YAML/JSON manifests
- Validates requests
- Stores cluster state in etcd

### Commands

    kubectl get pods
    kubectl apply -f app.yml

---

## 2. etcd

`etcd` is a distributed key-value database.

It stores the entire Kubernetes cluster state.

It stores:
- Pods
- Deployments
- Services
- Secrets
- ConfigMaps
- Other Kubernetes resources

It is the **source of truth** for the cluster.

### Example data stored in etcd

    /registry/pods/default/my-pod
    /registry/deployments/default/my-app
    /registry/secrets/default/my-secret

### Important

Always backup etcd because it contains the cluster state.

---

## 3. Scheduler (`kube-scheduler`)

The Scheduler decides which worker node should run a new Pod.

It looks at:
- Resource requests
- Node capacity
- Taints
- Affinity rules
- Scheduling constraints

The Scheduler does **not** run the Pod. It only assigns the Pod to a node.

### Scheduling Flow

    New Pod Created
          |
          v
    Scheduler evaluates nodes
          |
          ├── Node 1: 80% CPU → NO
          ├── Node 2: 30% CPU → YES
          └── Node 3: 60% CPU → Possible

---

## 4. Controller Manager (`kube-controller-manager`)

The Controller Manager runs multiple controllers continuously.

Each controller watches the cluster state and fixes differences between the desired state and actual state.

| Controller | What it does |
|---|---|
| Deployment Controller | Ensures desired replica count |
| Node Controller | Detects node failures |
| ReplicaSet Controller | Maintains Pod replicas |
| Endpoints Controller | Updates Service endpoints |

### Watch Loop

    Desired State
          |
          v
    Actual State
          |
          v
    Is Actual State = Desired State?
          |
       ┌──┴──┐
       |     |
      YES    NO
       |     |
    Do      Take action
    nothing to fix it

---

# Worker Node Components

## 5. kubelet

`kubelet` is the agent running on every worker node.

It:
- Watches the API Server for Pods assigned to the node
- Tells the container runtime to start/stop containers
- Reports Pod status back to the API Server

### Flow

    API Server
        |
        | "Start Pod X on Node 2"
        v
    kubelet on Node 2
        |
        | "Starting container..."
        v
    Container Runtime
        |
        v
    Pod Running
        |
        v
    kubelet reports status

---

## 6. kube-proxy

`kube-proxy` handles networking on each node.

It helps implement Service networking and routes traffic to the correct Pods.

### Example

    User
      |
      v
    Service IP:80
      |
      v
    kube-proxy
      |
      v
    Pod IP:8080

---

## 7. Container Runtime

The container runtime is the software that actually runs containers.

Modern Kubernetes commonly uses:

- `containerd`
- `CRI-O`

Kubernetes does not directly require Docker as the container runtime.

### Check Runtime

    kubectl get nodes -o wide

---

# Kubernetes Objects (Resources)

Everything in Kubernetes is represented as an object/resource described using YAML.

| Object | Purpose |
|---|---|
| Pod | Smallest unit — one or more containers |
| Deployment | Manages Pod replicas and rolling updates |
| Service | Stable network endpoint for Pods |
| ConfigMap | Non-secret configuration data |
| Secret | Sensitive configuration/data |
| Namespace | Virtual isolation |
| Ingress | HTTP/HTTPS routing |
| PersistentVolume | Persistent storage |
| Node | Worker machine |

---

# Namespaces — Virtual Isolation

Namespaces provide logical separation inside a Kubernetes cluster.

## List All Namespaces

    kubectl get namespaces

### Default Namespaces

    default          → Where your applications go by default
    kube-system      → Kubernetes system components
    kube-public      → Publicly accessible information
    kube-node-lease  → Node heartbeat data

## Create a Namespace

    kubectl create namespace my-app

## Run Commands in a Specific Namespace

    kubectl get pods -n kube-system
    kubectl get pods -n my-app

## Set Default Namespace

    kubectl config set-context --current --namespace=my-app

---

# kubectl — The Kubernetes CLI

`kubectl` is the command-line tool used to communicate with Kubernetes clusters.

## Check Cluster Connection

    kubectl cluster-info

## View Nodes

    kubectl get nodes
    kubectl get nodes -o wide

## View All Resources

    kubectl get all
    kubectl get all -n kube-system

## Describe a Resource

    kubectl describe node NODE_NAME

## Check API Server URL

    kubectl cluster-info | grep "Kubernetes control plane"

---

# k3s — Lightweight Kubernetes

k3s is a lightweight Kubernetes distribution.

It is useful for:

- Low-resource machines
- Development
- Learning Kubernetes
- Edge computing
- EC2 instances with limited memory

---

# Install k3s on Amazon Linux

    curl -sfL https://get.k3s.io | sh -

## Check k3s Service

    sudo systemctl status k3s

## Check Nodes

    sudo kubectl get nodes

## k3s kubeconfig Location

    sudo cat /etc/rancher/k3s/k3s.yaml

---

# Configure kubeconfig for Current User

    mkdir -p ~/.kube

    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

    sudo chown $(id -u):$(id -g) ~/.kube/config

Now use kubectl without sudo:

    kubectl get nodes

Check all namespaces:

    kubectl get pods -A

---

# kubectl vs k3s

| kubectl | k3s |
|---|---|
| CLI tool | Lightweight Kubernetes distribution |
| Kubernetes client | Full lightweight Kubernetes distribution |
| Connects to existing clusters | Can run/manage a Kubernetes cluster |
| Very small resource usage | Designed for lightweight environments |
| Used to manage Kubernetes | Provides Kubernetes environment |

---

# Practice Commands

## Connect to EC2 Server

    ssh -i ~/Downloads/nehanew.pem ec2-user@YOUR_EC2_PUBLIC_DNS

## Install k3s

    curl -sfL https://get.k3s.io | sh -

## Check Cluster Health

    sudo kubectl get nodes
    sudo kubectl get pods -A

## Set Up kubeconfig

    mkdir -p ~/.kube

    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

    sudo chown $(id -u):$(id -g) ~/.kube/config

    export KUBECONFIG=~/.kube/config

## Explore Cluster

    kubectl get nodes -o wide
    kubectl get namespaces
    kubectl get all -n kube-system
    kubectl cluster-info

## See API Resources

    kubectl api-resources | head -20

## Check Component Status

    kubectl get componentstatuses

---

# Kubernetes Architecture — Request Flow

When you run:

    kubectl apply -f app.yml

The basic flow is:

    kubectl
       |
       v
    API Server
       |
       v
    etcd
       |
       v
    Controller Manager
       |
       v
    Scheduler
       |
       v
    Worker Node
       |
       v
    kubelet
       |
       v
    Container Runtime
       |
       v
    Pod

---

# Key Responsibilities

| Component | Lives In | Role |
|---|---|---|
| API Server | Control Plane | Entry point, REST API |
| etcd | Control Plane | Stores cluster state |
| Scheduler | Control Plane | Assigns Pods to nodes |
| Controller Manager | Control Plane | Watches and fixes cluster state |
| kubelet | Worker Node | Runs Pods according to instructions |
| kube-proxy | Worker Node | Handles networking |
| containerd | Worker Node | Runs containers |

---

# Important Kubernetes Concept

Kubernetes is **declarative**.

You tell Kubernetes **WHAT you want**, not exactly **HOW to do it**.

### Example

    You:
    "I want 3 replicas of my application."

              |
              v

    Kubernetes:
    "I will make sure 3 replicas
    are always running."

              |
              v

    If one Pod crashes:

    Kubernetes:
    "Only 2 are running.
    I need 3."

              |
              v

    New Pod is created.

---

# Summary

- Kubernetes = Container orchestration platform
- K8s manages containers at scale
- Control Plane = Brain of the cluster
- API Server = Entry point for Kubernetes API
- etcd = Stores all cluster state
- Scheduler = Assigns Pods to worker nodes
- Controller Manager = Watches and fixes cluster state
- kubelet = Runs Pods on worker nodes
- kube-proxy = Handles Service networking
- containerd = Runs containers
- Pod = Smallest deployable Kubernetes unit
- Deployment = Manages replicas and rolling updates
- Service = Stable networking endpoint
- Namespace = Logical isolation
- kubectl = Kubernetes CLI
- k3s = Lightweight Kubernetes distribution
- Kubernetes follows a declarative model
- You define **WHAT** you want
- Kubernetes determines **HOW** to achieve it

# Key Concept to Remember

> You tell Kubernetes WHAT you want, and Kubernetes continuously works to make the actual state match the desired state.
