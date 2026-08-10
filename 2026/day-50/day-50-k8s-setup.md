 Day 50 — Kubernetes Architecture & Cluster Setup

  ---
  Concept: Why Kubernetes?

  Docker runs containers on one machine. But in production you have 100s of containers across multiple servers. You need something to:
  - Automatically start/stop containers
  - Handle failures (restart crashed containers)
  - Distribute load across servers
  - Scale up/down based on traffic

  That's Kubernetes (K8s) — a container orchestrator created by Google, inspired by their internal system called Borg. The name "Kubernetes" is Greek for
  "helmsman/pilot".

  ---
  Task 2: Kubernetes Architecture

  ┌─────────────────────────────────────────────┐
  │            CONTROL PLANE (Master)           │
  │                                             │
  │  API Server  ←── all kubectl commands       │
  │  etcd        ←── cluster state database     │
  │  Scheduler   ←── decides which node to use  │
  │  Controller  ←── watches & fixes state      │
  └─────────────────────────────────────────────┘
              ↕ communicates
  ┌──────────────────┐   ┌──────────────────┐
  │   Worker Node 1  │   │   Worker Node 2  │
  │  kubelet         │   │  kubelet         │
  │  kube-proxy      │   │  kube-proxy      │
  │  containerd      │   │  containerd      │
  │  [ Pod ] [ Pod ] │   │  [ Pod ] [ Pod ] │
  └──────────────────┘   └──────────────────┘

  What happens when you run kubectl apply -f pod.yaml?
  1. kubectl sends request to API Server
  2. API Server saves desired state in etcd
  3. Scheduler picks which node to place the pod on
  4. kubelet on that node pulls the image and starts the container

  ---
  Task 3: Install kubectl

  macOS:
  brew install kubectl
  kubectl version --client

  Linux (your EC2):
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  kubectl version --client

  ---
  Task 4: Setup Local Cluster

  Option A — kind (Kubernetes in Docker):
  # Install (macOS)
  brew install kind

  # Install (Linux)
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
  chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind

  # Create cluster
  kind create cluster --name devops-cluster

  # Verify
  kubectl cluster-info
  kubectl get nodes

  Option B — minikube:
  # Install (macOS)
  brew install minikube

  # Start
  minikube start

  # Verify
  kubectl cluster-info
  kubectl get nodes

  ▎ For EC2 (Linux), you already have k3s installed — that's even better, it's a lightweight full K8s.

  ---
  Task 5: Explore Your Cluster

  kubectl cluster-info                     # cluster endpoint info

  kubectl get nodes                        # list all nodes
  kubectl get nodes -o wide               # with IP, OS, container runtime

  kubectl describe node <node-name>        # full details of a node

  kubectl get namespaces                   # list all namespaces

  kubectl get pods -A                      # all pods in ALL namespaces

  kubectl get pods -n kube-system          # system pods (control plane components)

  You should see these in kube-system:

  ┌─────────────────────────┬────────────────────────────────────┐
  │           Pod           │            What it does            │
  ├─────────────────────────┼────────────────────────────────────┤
  │ etcd                    │ Cluster state database             │
  ├─────────────────────────┼────────────────────────────────────┤
  │ kube-apiserver          │ Front door — handles all API calls │
  ├─────────────────────────┼────────────────────────────────────┤
  │ kube-scheduler          │ Assigns pods to nodes              │
  ├─────────────────────────┼────────────────────────────────────┤
  │ kube-controller-manager │ Watches & maintains desired state  │
  ├─────────────────────────┼────────────────────────────────────┤
  │ coredns                 │ DNS for pods inside cluster        │
  ├─────────────────────────┼────────────────────────────────────┤
  │ kube-proxy              │ Networking rules on each node      │
  └─────────────────────────┴────────────────────────────────────┘

  ---
  Task 6: Cluster Lifecycle + kubeconfig

  # Delete cluster
  kind delete cluster --name devops-cluster
  # OR
  minikube delete

  # Recreate
  kind create cluster --name devops-cluster
  kubectl get nodes

  # Which cluster am I connected to?
  kubectl config current-context

  # List all clusters/contexts
  kubectl config get-contexts

  # View full kubeconfig
  kubectl config view

  What is kubeconfig?
  - A file at ~/.kube/config
  - Stores cluster address, credentials, and context
  - kubectl reads this to know which cluster to talk to

  cat ~/.kube/config          # view it

  ---
  Summary: Day 50 Key Points

  ┌───────────────┬─────────────────────────────────────────────────┐
  │    Concept    │                    One Line                     │
  ├───────────────┼─────────────────────────────────────────────────┤
  │ Kubernetes    │ Orchestrates containers at scale                │
  ├───────────────┼─────────────────────────────────────────────────┤
  │ Control Plane │ Brain — API Server, etcd, Scheduler, Controller │
  ├───────────────┼─────────────────────────────────────────────────┤
  │ Worker Node   │ Runs containers — kubelet, kube-proxy, runtime  │
  ├───────────────┼─────────────────────────────────────────────────┤
  │ kubectl       │ CLI to talk to the cluster                      │
  ├───────────────┼─────────────────────────────────────────────────┤
  │ kubeconfig    │ ~/.kube/config — stores cluster connection info │
  ├───────────────┼─────────────────────────────────────────────────┤
  │ kind/minikube │ Local cluster tools for practice                │
  └───────────────┴─────────────────────────────────────────────────┘

  ---
