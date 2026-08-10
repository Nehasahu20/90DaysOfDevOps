# Day 52 — Kubernetes Namespaces, Deployments, Scaling & Rolling Updates

## Kubernetes Namespace

### Definition

A **Kubernetes Namespace** is a logical isolation boundary inside a Kubernetes cluster. It is used to organize, separate, and manage resources such as Pods, Deployments, and Services within the same cluster.

### What is a Namespace?

A **Namespace** is a virtual cluster inside your Kubernetes cluster.

It is used to isolate and organize resources.

**Example:**

- `dev` → dev team's pods/deployments
- `staging` → staging environment
- `production` → production workloads
- `kube-system` → Kubernetes internal components

### Task 1 — Explore Default Namespaces

```bash
kubectl get namespaces

# You'll see:
# default          → your resources go here if no namespace is specified
# kube-system      → API server, scheduler, etcd pods live here
# kube-public      → publicly readable resources
# kube-node-lease  → node heartbeat tracking

kubectl get pods -n kube-system
```

### Task 2 — Create Custom Namespaces

#### Imperative Way

```bash
kubectl create namespace dev
kubectl create namespace staging
```

#### Declarative Way

```bash
cat <<EOF > namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
EOF

kubectl apply -f namespace.yaml

kubectl get namespaces
```

### Run Pods in Specific Namespaces

```bash
kubectl run nginx-dev --image=nginx:latest -n dev
kubectl run nginx-staging --image=nginx:latest -n staging

kubectl get pods          # Shows NOTHING from dev/staging because this checks default namespace
kubectl get pods -n dev   # Shows nginx-dev
kubectl get pods -A       # Shows ALL pods across ALL namespaces
```

---

## Kubernetes Deployment

### Definition

A **Kubernetes Deployment** is a controller that manages a set of Pods and ensures that the desired number of replicas are running. It also supports scaling, rolling updates, and rollbacks.

### What is a Deployment?

A **Deployment** is a blueprint that says:

> "Always keep X replicas of this Pod running."

If a Pod crashes, the Deployment controller detects the mismatch and creates a new Pod.

If a node dies, Kubernetes can recreate the Pod on a healthy node.

If you want more replicas, you can scale the Deployment with one command.

### Deployment Structure

```text
Deployment
    └── ReplicaSet (manages pod count)
            ├── Pod 1
            ├── Pod 2
            └── Pod 3
```

### Task 3 — Create a Deployment

```bash
cat <<EOF > nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: dev
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.24
          ports:
            - containerPort: 80
EOF

kubectl apply -f nginx-deployment.yaml

kubectl get deployments -n dev
kubectl get pods -n dev
```

### Deployment YAML Explained

| Field | Meaning |
|---|---|
| `apiVersion: apps/v1` | Deployments use `apps/v1`, not `v1` |
| `replicas: 3` | Always keep 3 Pods running |
| `selector.matchLabels` | Tells the Deployment which Pods it owns |
| `template` | Blueprint for creating Pods |
| `template.metadata.labels` | Must match `selector.matchLabels` |

### Deployment Output Columns

```bash
kubectl get deployments -n dev
```

- **READY** → Pods ready / desired, for example `2/3`
- **UP-TO-DATE** → Pods updated to the latest specification
- **AVAILABLE** → Pods available to serve traffic

---

## Kubernetes Self-Healing

### Definition

**Self-healing** is Kubernetes' ability to automatically maintain the desired state of workloads. When a Pod managed by a Deployment is deleted or fails, Kubernetes creates a replacement Pod to maintain the configured replica count.

### Delete a Pod and Watch It Come Back

First check the Pods:

```bash
kubectl get pods -n dev
```

Note one Pod name, then delete it:

```bash
kubectl delete pod <pod-name> -n dev
```

Immediately check again:

```bash
kubectl get pods -n dev
```

You will see a new Pod being created.

The new Pod has a **different name** because it is a brand-new Pod created by the Deployment.

---

## Kubernetes Scaling

### Definition

**Scaling** is the process of increasing or decreasing the number of Pod replicas running for an application according to workload requirements. Kubernetes allows a Deployment to be scaled up or down by changing its desired replica count.

### Scale Up and Down

#### Scale Up to 5 Pods

```bash
kubectl scale deployment nginx-deployment --replicas=5 -n dev
kubectl get pods -n dev
```

You should now have 5 Pods.

#### Scale Down to 2 Pods

```bash
kubectl scale deployment nginx-deployment --replicas=2 -n dev
kubectl get pods -n dev
```

Three Pods will be terminated and two will remain.

#### Declarative Scaling

Edit the YAML:

```yaml
replicas: 4
```

Then apply it:

```bash
kubectl apply -f nginx-deployment.yaml
```

---

## Kubernetes Rolling Updates & Rollbacks

### Definitions

**Rolling Update:** A rolling update gradually replaces old Pods with new Pods when an application version or container image changes, helping maintain application availability during the update.

**Rollback:** A rollback restores a Deployment to a previous revision when the new version has problems or needs to be reverted.

### Update Image Version

Update Nginx from `1.24` to `1.25`:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
```

Watch the rollout:

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

Kubernetes replaces Pods one by one.

An old Pod is removed only after the new Pod is healthy.

This provides **zero-downtime rolling updates** when the Deployment strategy and application are configured appropriately.

### Rolling Update Flow

```text
Before:
[Pod-1.24] [Pod-1.24] [Pod-1.24]

Step 1:
[Pod-1.24] [Pod-1.24] [Pod-1.25]
                         ↑
                    New Pod started

Step 2:
[Pod-1.24] [Pod-1.25] [Pod-1.25]
             ↑
       Old Pod replaced

Step 3:
[Pod-1.25] [Pod-1.25] [Pod-1.25]
                         ↑
                  Rollout complete
```

### Check Rollout History

```bash
kubectl rollout history deployment/nginx-deployment -n dev
```

### Roll Back to Previous Version

```bash
kubectl rollout undo deployment/nginx-deployment -n dev
```

Watch the rollback:

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

Verify the image:

```bash
kubectl describe deployment nginx-deployment -n dev | grep Image
```

It should show:

```text
nginx:1.24
```

---

## Kubernetes Cleanup

### Definition

**Cleanup** means removing Kubernetes resources that are no longer needed, such as Deployments, Pods, and Namespaces. Deleting a Namespace also deletes the resources contained inside it.

Delete the Deployment:

```bash
kubectl delete deployment nginx-deployment -n dev
```

Delete the test Pods:

```bash
kubectl delete pod nginx-dev -n dev
kubectl delete pod nginx-staging -n staging
```

### Delete Entire Namespaces

```bash
kubectl delete namespace dev staging production
```

Verify:

```bash
kubectl get namespaces
kubectl get pods -A
```

> **Warning:** Deleting a namespace deletes all resources inside it. Be extremely careful when doing this in production.

---

## Practice Flow — Complete Command Set

```bash
# Check namespaces
kubectl get namespaces

# Create namespaces
kubectl create namespace dev
kubectl create namespace staging

# Create production namespace using YAML
cat <<EOF > namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
EOF

kubectl apply -f namespace.yaml

# Run Pods in different namespaces
kubectl run nginx-dev --image=nginx:latest -n dev
kubectl run nginx-staging --image=nginx:latest -n staging

# Check Pods
kubectl get pods
kubectl get pods -n dev
kubectl get pods -n staging
kubectl get pods -A

# Create Deployment
cat <<EOF > nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: dev
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.24
          ports:
            - containerPort: 80
EOF

kubectl apply -f nginx-deployment.yaml

# Check Deployment and Pods
kubectl get deployments -n dev
kubectl get pods -n dev

# Test self-healing
kubectl get pods -n dev
kubectl delete pod <pod-name> -n dev
kubectl get pods -n dev

# Scale up
kubectl scale deployment nginx-deployment --replicas=5 -n dev
kubectl get pods -n dev

# Scale down
kubectl scale deployment nginx-deployment --replicas=2 -n dev
kubectl get pods -n dev

# Rolling update
kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
kubectl rollout status deployment/nginx-deployment -n dev

# Check rollout history
kubectl rollout history deployment/nginx-deployment -n dev

# Rollback
kubectl rollout undo deployment/nginx-deployment -n dev
kubectl rollout status deployment/nginx-deployment -n dev

# Verify image
kubectl describe deployment nginx-deployment -n dev | grep Image

# Clean up
kubectl delete deployment nginx-deployment -n dev
kubectl delete pod nginx-dev -n dev
kubectl delete pod nginx-staging -n staging

# Delete namespaces
kubectl delete namespace dev staging production

# Verify cleanup
kubectl get namespaces
kubectl get pods -A
```

---

## Summary

| Concept | Key Point |
|---|---|
| Namespace | Isolates resources — like folders inside a cluster |
| `kubectl get pods -n <ns>` | See Pods in a specific namespace |
| `kubectl get pods -A` | See Pods across all namespaces |
| Deployment | Maintains the desired number of Pods |
| Self-healing | Deleted/crashed Pod → Deployment recreates it automatically |
| Scaling | `kubectl scale --replicas=N` changes the desired Pod count |
| Rolling update | `kubectl set image` updates Pods gradually |
| Rollback | `kubectl rollout undo` returns to the previous version |
| Delete namespace | Removes everything inside the namespace — use carefully |

## Key Concepts to Remember

- **Namespace** → Organizes and isolates Kubernetes resources.
- **Deployment** → Maintains the desired number of Pod replicas.
- **ReplicaSet** → Ensures the required number of Pods exist.
- **Self-healing** → Kubernetes automatically replaces failed or deleted Pods managed by a Deployment.
- **Scaling** → Increase or decrease replicas according to workload requirements.
- **Rolling update** → Update application versions gradually without stopping the entire application.
- **Rollback** → Quickly return to a previous working version.
- **Namespace deletion** → Deletes all resources inside that namespace.

> **Important:** Pods are ephemeral. For reliable applications, manage Pods through higher-level resources such as Deployments instead of creating individual Pods directly.
