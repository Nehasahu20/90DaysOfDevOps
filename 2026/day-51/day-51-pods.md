# Day 51 — Kubernetes Pods

## What is a Pod?

A Pod is the smallest deployable unit in Kubernetes.

A Pod:
- Contains one or more containers
- Gives all containers in the Pod a shared network
- Gives all containers in the Pod a shared IP address
- Can share storage volumes between containers
- Allows containers inside the same Pod to communicate using `localhost`

### Pod Architecture

    ┌─────────────────────────────────┐
    │               POD               │
    │          IP: 10.244.0.5         │
    │                                 │
    │  ┌─────────────┐ ┌───────────┐ │
    │  │ Container 1 │ │Container 2│ │
    │  │    (app)    │ │ (sidecar) │ │
    │  │  port: 8080 │ │ port: 9090│ │
    │  └─────────────┘ └───────────┘ │
    │                                 │
    │ Shared: /data volume, network   │
    └─────────────────────────────────┘

---

# Imperative vs Declarative

## Imperative

Imperative means running commands directly.

    kubectl run my-pod --image=nginx
    kubectl run my-pod --image=nginx --port=80

Advantages:
- Quick for testing
- Easy for simple experiments

Disadvantages:
- Not easily reproducible
- Not version controlled
- Not ideal for production

## Declarative

Declarative means defining the desired state in YAML and applying it.

    kubectl apply -f my-pod.yml

Advantages:
- Reproducible
- Version controlled
- Production ready
- Easy to review and maintain

---

# Pod YAML Manifest Structure

Every Kubernetes YAML commonly contains these top-level fields:

    apiVersion: v1
    kind: Pod
    metadata:
      name: my-pod
      labels:
        app: my-app
    spec:
      containers:
        - name: my-container
          image: nginx:latest
          ports:
            - containerPort: 80

## Important Fields

| Field | Purpose |
|---|---|
| `apiVersion` | API group/version |
| `kind` | Type of Kubernetes resource |
| `metadata` | Name, labels, namespace |
| `spec` | Desired configuration |

---

# API Versions for Common Resources

| Resource | apiVersion |
|---|---|
| Pod | v1 |
| Service | v1 |
| Deployment | apps/v1 |
| ReplicaSet | apps/v1 |
| Ingress | networking.k8s.io/v1 |

---

# Minimal Pod — Nginx

File: `simple-pod.yaml`

    apiVersion: v1
    kind: Pod
    metadata:
      name: simple-nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80

## Apply the Pod

    kubectl apply -f simple-pod.yaml

## Check the Pod

    kubectl get pods

## Describe the Pod

    kubectl describe pod simple-nginx

---

# Full Pod YAML — Common Options

    apiVersion: v1
    kind: Pod
    metadata:
      name: my-app-pod
      namespace: default
      labels:
        app: my-app
        version: v1.0
        environment: production
    spec:
      containers:
        - name: app-container
          image: nginx:1.25
          ports:
            - containerPort: 80
              name: http
            - containerPort: 443
              name: https

          # Environment variables
          env:
            - name: APP_ENV
              value: "production"
            - name: LOG_LEVEL
              value: "info"

          # Resource limits
          resources:
            requests:
              memory: "64Mi"
              cpu: "250m"
            limits:
              memory: "128Mi"
              cpu: "500m"

          # Readiness Probe
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 10

          # Liveness Probe
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 15
            periodSeconds: 20

      restartPolicy: Always

---

# Resource Units

## CPU

    1 CPU    = 1000m
    0.5 CPU  = 500m
    0.25 CPU = 250m

`m` means millicores.

For example:

    250m = 0.25 CPU
    500m = 0.5 CPU

## Memory

Common memory units:

    Mi = Mebibytes
    Gi = Gibibytes

Examples:

    128Mi ≈ 128 MB
    1Gi   ≈ 1 GB

Technically:

    1 Mi = 1,048,576 bytes

---

# Health Checks

## Readiness Probe

A readiness probe checks:

> "Is this Pod ready to receive traffic?"

Example:

    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10

If the readiness probe fails, Kubernetes can stop sending traffic to that Pod through a Service.

## Liveness Probe

A liveness probe checks:

> "Is this container still alive?"

Example:

    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 15
      periodSeconds: 20

If the liveness probe repeatedly fails, Kubernetes can restart the container.

---

# Restart Policy

A Pod can use:

    restartPolicy: Always

    restartPolicy: OnFailure

    restartPolicy: Never

### Meaning

| Policy | Meaning |
|---|---|
| Always | Restart containers whenever they exit |
| OnFailure | Restart only when the container exits with non-zero status |
| Never | Never restart containers |

`Always` is the default for Pods created by most controllers such as Deployments.

---

# Labels

Labels are key-value pairs attached to Kubernetes resources.

They are used for:
- Selecting resources
- Filtering resources
- Grouping resources
- Connecting resources such as Services to Pods

Example:

    metadata:
      labels:
        app: frontend
        version: v2.0
        team: platform
        environment: prod

---

# Using Labels

## Get Pods with Specific Label

    kubectl get pods -l app=frontend

## Filter by Environment

    kubectl get pods -l environment=prod

## Multiple Labels

    kubectl get pods -l app=frontend,version=v2.0

## Show All Pod Labels

    kubectl get pods --show-labels

## Add a Label

    kubectl label pod my-pod color=blue

## Remove a Label

    kubectl label pod my-pod color-

The `-` removes the label.

## Update a Label

    kubectl label pod my-pod version=v3.0 --overwrite

---

# kubectl — Pod Commands

## Creating Pods

### Declarative — Recommended

    kubectl apply -f pod.yaml

### Imperative — Quick Test

    kubectl run my-pod --image=nginx

    kubectl run my-pod --image=nginx --port=80

### Generate YAML Without Creating the Pod

    kubectl run my-pod --image=nginx --dry-run=client -o yaml

---

# Viewing Pods

## Basic List

    kubectl get pods

## More Details

    kubectl get pods -o wide

This shows additional information such as:
- Pod IP
- Node
- Status

## Full Details

    kubectl describe pod my-pod

## Watch Pods in Real Time

    kubectl get pods -w

`-w` means watch.

## Pods in All Namespaces

    kubectl get pods -A

or:

    kubectl get pods --all-namespaces

## YAML Output

    kubectl get pod my-pod -o yaml

## JSON Output

    kubectl get pod my-pod -o json

---

# Interacting with Pods

## Execute a Command

    kubectl exec my-pod -- ls /

    kubectl exec my-pod -- cat /etc/nginx/nginx.conf

## Interactive Shell

    kubectl exec -it my-pod -- /bin/bash

If Bash is not available:

    kubectl exec -it my-pod -- /bin/sh

## Multiple Containers

If a Pod has multiple containers, specify the container:

    kubectl exec -it my-pod -c my-container -- /bin/bash

---

# Pod Logs

## View Logs

    kubectl logs my-pod

## Follow Logs

    kubectl logs my-pod -f

This works similar to `tail -f`.

## Last 50 Lines

    kubectl logs my-pod --tail=50

## Logs from Last Hour

    kubectl logs my-pod --since=1h

## Logs from Specific Container

    kubectl logs my-pod -c sidecar

---

# Deleting Pods

## Delete a Pod

    kubectl delete pod my-pod

## Delete Using YAML

    kubectl delete -f pod.yaml

## Delete All Pods in Namespace

    kubectl delete pods --all

## Delete Pods by Label

    kubectl delete pods -l app=my-app

---

# Pod Lifecycle

The basic Pod lifecycle is:

    Pending → Running → Succeeded

or:

    Pending → Running → Failed

## Pending

Pod is scheduled or waiting for its containers to start.

Possible reasons:
- Insufficient resources
- Image pulling
- Volume issues
- Scheduling problems

## Running

At least one container in the Pod is running.

## Succeeded

All containers exited successfully with exit code `0`.

## Failed

At least one container exited with a non-zero exit code.

## Unknown

Kubernetes cannot determine the Pod state, usually because communication with the node has failed.

---

# Multi-Container Pod

A Pod can contain multiple containers.

Common use cases:
- Sidecar containers
- Logging
- Monitoring
- Proxy containers
- Supporting processes

Example:

    apiVersion: v1
    kind: Pod
    metadata:
      name: web-with-logger
    spec:
      containers:
        - name: web
          image: nginx
          ports:
            - containerPort: 80
          volumeMounts:
            - name: log-volume
              mountPath: /var/log/nginx

        - name: log-watcher
          image: busybox
          command: ["/bin/sh", "-c", "tail -f /var/log/nginx/access.log"]
          volumeMounts:
            - name: log-volume
              mountPath: /var/log/nginx

      volumes:
        - name: log-volume
          emptyDir: {}

## Apply Multi-Container Pod

    kubectl apply -f multi-container.yaml

## Logs from Main Container

    kubectl logs web-with-logger -c web

## Logs from Sidecar Container

    kubectl logs web-with-logger -c log-watcher

---

# Shared Networking in Multi-Container Pods

Containers inside the same Pod share the same network namespace.

Therefore:

- They share the same Pod IP
- They can communicate using `localhost`
- Each container must use different ports if they need to listen on the same interface

Example:

    Container 1 → localhost:8080
    Container 2 → localhost:9090

Both containers use the same Pod IP.

---

# Shared Storage in Multi-Container Pods

Containers in the same Pod can share volumes.

Example:

    volumes:
      - name: log-volume
        emptyDir: {}

The volume can then be mounted by multiple containers.

This is useful for sidecar logging patterns.

---

# Init Containers

Init containers run **before** the main application containers start.

They are commonly used for:
- Setup tasks
- Initialization
- Preparing files
- Waiting for dependencies
- Database initialization

Example:

    apiVersion: v1
    kind: Pod
    metadata:
      name: init-example
    spec:
      initContainers:
        - name: setup
          image: busybox
          command:
            - sh
            - -c
            - echo "Setting up..." && sleep 5

      containers:
        - name: main-app
          image: nginx

### Init Container Flow

    Init Container
          |
          v
    Setup Complete
          |
          v
    Main Container Starts

---

# Practice Exercises

## Exercise 1: Create and Explore a Pod

### Create Nginx Pod

Create `simple-pod.yaml`:

    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx-pod
      labels:
        app: nginx
        version: "1.25"
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80

### Apply

    kubectl apply -f simple-pod.yaml

### Check Pods

    kubectl get pods

### Get More Information

    kubectl get pods -o wide

### Describe Pod

    kubectl describe pod nginx-pod

---

# Exercise 2: Exec into a Pod

## Execute Commands

    kubectl exec nginx-pod -- nginx -v

    kubectl exec nginx-pod -- ls /etc/nginx

## Interactive Shell

    kubectl exec -it nginx-pod -- /bin/bash

Inside the Pod:

    curl http://localhost

    cat /etc/nginx/nginx.conf

Exit:

    exit

---

# Exercise 3: View Logs

    kubectl logs nginx-pod

Follow logs:

    kubectl logs nginx-pod -f

Last 20 lines:

    kubectl logs nginx-pod --tail=20

---

# Exercise 4: Labels

## Show Labels

    kubectl get pods --show-labels

## Add Label

    kubectl label pod nginx-pod team=devops

## Select by Label

    kubectl get pods -l app=nginx

    kubectl get pods -l team=devops

---

# Exercise 5: Generate YAML from Imperative Command

Generate YAML without creating the Pod:

    kubectl run test-pod --image=nginx --port=80 --dry-run=client -o yaml

Save the generated YAML:

    kubectl run test-pod --image=nginx --port=80 --dry-run=client -o yaml > test-pod.yaml

View the YAML:

    cat test-pod.yaml

Apply it:

    kubectl apply -f test-pod.yaml

---

# Exercise 6: Delete Pod and Watch

Watch Pods in the background:

    kubectl get pods -w &

Delete the Pod:

    kubectl delete pod nginx-pod

You will see:

    nginx-pod Terminating → disappears

---

# Debugging Pods

## Pod is Pending

Check details:

    kubectl describe pod my-pod

Look at the `Events:` section near the bottom.

### Common Reasons

- Not enough CPU on nodes
- Not enough memory on nodes
- Image cannot be pulled
- Persistent volume not found
- Scheduling constraints
- Node problems

---

# Pod is CrashLoopBackOff

The container is repeatedly crashing and restarting.

Check current logs:

    kubectl logs my-pod

Check logs from the previous crash:

    kubectl logs my-pod --previous

Check events:

    kubectl describe pod my-pod

---

# Pod is ImagePullBackOff

This usually means Kubernetes cannot pull the container image.

Possible reasons:
- Image name is incorrect
- Image tag does not exist
- Private registry requires authentication
- Registry is unavailable
- Network issue

Check events:

    kubectl describe pod my-pod | grep -A5 Events

---

# Useful Pod Debugging Commands

    kubectl get pods

    kubectl get pods -o wide

    kubectl describe pod my-pod

    kubectl logs my-pod

    kubectl logs my-pod --previous

    kubectl get events

    kubectl get events --sort-by=.metadata.creationTimestamp

---

# Pod Commands Cheat Sheet

| Command | Purpose |
|---|---|
| `kubectl apply -f file.yaml` | Create/update from YAML |
| `kubectl get pods` | List all Pods |
| `kubectl get pods -o wide` | List Pods with node + IP |
| `kubectl describe pod NAME` | Full details + events |
| `kubectl logs NAME` | View container logs |
| `kubectl exec -it NAME -- /bin/sh` | Open shell inside Pod |
| `kubectl delete pod NAME` | Delete a Pod |
| `kubectl label pod NAME key=val` | Add/update label |
| `kubectl get pods -l key=val` | Filter Pods by label |
| `kubectl get pods -w` | Watch Pod changes |
| `kubectl get pod NAME -o yaml` | View Pod YAML |
| `kubectl get pod NAME -o json` | View Pod JSON |

---

# Important Pod Concepts

## Pod = Smallest Deployable Unit

A Pod can contain:
- One container
- Multiple tightly coupled containers

## Pod IP

A Pod has one IP address.

All containers inside that Pod share the same network namespace.

## localhost

Containers in the same Pod can communicate through `localhost`.

## Shared Storage

Containers can share volumes mounted inside the Pod.

## Pods Are Ephemeral

Pods are temporary.

A Pod can be:
- Deleted
- Recreated
- Rescheduled
- Replaced

Therefore, do not expect an individual Pod to live forever.

---

# Why Deployments Are Important

For production applications, you normally do not manage individual Pods manually.

Instead, use a Deployment.

The Deployment can:
- Maintain the desired number of replicas
- Recreate failed Pods
- Perform rolling updates
- Roll back deployments
- Maintain application availability

Example concept:

    Deployment
        |
        ├── Pod 1
        ├── Pod 2
        └── Pod 3

If Pod 2 crashes:

    Deployment
        |
        ├── Pod 1
        ├── Pod 3
        └── New Pod 4

The Deployment maintains the desired replica count.

---

# Summary

- Pod is the smallest deployable unit in Kubernetes.
- A Pod can contain one or more containers.
- Containers inside a Pod share the same network namespace.
- Containers inside a Pod share the same Pod IP.
- Containers in the same Pod can communicate through `localhost`.
- Containers can share storage using volumes.
- Declarative YAML is recommended for production.
- `kubectl apply -f` creates or updates resources from YAML.
- Labels are used for selecting, filtering, and grouping resources.
- Readiness probes determine whether a Pod is ready to receive traffic.
- Liveness probes determine whether a container is still healthy.
- Resource requests define minimum guaranteed resources.
- Resource limits define maximum allowed resources.
- Init containers run before the main containers.
- Multi-container Pods are commonly used with sidecar patterns.
- `kubectl logs` is used to inspect container logs.
- `kubectl exec` is used to execute commands inside containers.
- `kubectl describe` is useful for debugging.
- `CrashLoopBackOff` usually means a container is repeatedly crashing.
- `ImagePullBackOff` usually means Kubernetes cannot pull the image.
- Pods are ephemeral and should not normally be managed individually in production.
- Deployments should be used to manage Pods reliably.

# Key Concept

> Pods are ephemeral. Don't expect individual Pods to last forever. Use Deployments to manage Pods reliably.
