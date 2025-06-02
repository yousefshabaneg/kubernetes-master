# Kubernetes Mastery

<div align="center">
  <img src="https://www.elizeire.com/assets/img/kubernetes-horizontal-color.png" alt="Kubernetes Logo" />
  <br/>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT" /></a>
  <a href="https://kubernetes.io/"><img src="https://img.shields.io/badge/Kubernetes-1.28-blue" alt="Kubernetes" /></a>
  <a href="https://kind.sigs.k8s.io/"><img src="https://img.shields.io/badge/Kind-v0.20.0-blue" alt="Kind" /></a>
</div>

---

## 📚 Table of Contents

- [Overview](#🎯-overview)
- [Prerequisites](#🔧-prerequisites)
- [Tools Explained](#🔍-tools-explained)
- [Kubernetes Core Components: Deep Dive](#🧱-kubernetes-core-components-deep-dive)
- [Project Structure](#📁-project-structure)
- [Kubernetes Concepts](#🎓-kubernetes-concepts)
- [Getting Started](#🚀-getting-started)
- [Project Implementation](#🏗️-project-implementation)
- [Monitoring & Scaling](#🩺-monitoring--scaling)
- [Best Practices](#💡-best-practices)
- [Contributing](#🤝-contributing)
- [License](#📄-license)

---

## 🎯 Overview

This repository is a comprehensive hands-on guide for mastering Kubernetes using real-world components and structured labs. It provides both theoretical insights and practical YAML manifests for deploying scalable applications in a Kubernetes environment.

---

## 🔧 Prerequisites

### Required Tools

- **Docker**: Container engine used to build and run containers
- **Kind**: Tool for running Kubernetes clusters locally using Docker containers
- **kubectl**: Command-line tool to interact with Kubernetes clusters

---

## 🔍 Tools Explained

### Kubernetes

- **Definition**: Open-source container orchestration system for automating application deployment, scaling, and management.
- **Strengths**: Resilience, self-healing, autoscaling, extensibility via CRDs.
- **Comparison**:
  | Feature | Docker Compose | Kubernetes |
  |------------------|----------------|------------------|
  | Orchestration | Manual | Automated |
  | Scaling | Manual | Horizontal Pods |
  | Health Checks | Basic | Probes & Restarts|

### `kubectl`

- **Definition**: CLI for managing Kubernetes resources.
- **Common Usage**:
  ```bash
  kubectl get pods
  kubectl apply -f deployment.yaml
  kubectl describe service weatherapp-ui
  ```

### `kind`

- **Definition**: "Kubernetes IN Docker" – spins up a local cluster using Docker containers.
- **Use Case**: Ideal for CI pipelines and development testing.

---

## 🧱 Kubernetes Core Components: Deep Dive

This section serves as a hands-on developer reference for Kubernetes primitives. Each core object is explained with its purpose, types (if applicable), real-world use cases, CLI usage, and ready-to-use YAML templates.

---

### 🚀 Deployment

**Definition**: A controller that manages stateless application pods. Ensures the desired number of pod replicas are always available and automatically replaces failed pods.

**Use Cases**:

- Running microservices
- Stateless web applications
- Auto-scaling with `HorizontalPodAutoscaler`

**Key `kubectl` Commands**:

```bash
kubectl create deployment nginx --image=nginx
kubectl get deployments
kubectl describe deployment nginx
kubectl scale deployment nginx --replicas=5
kubectl delete deployment nginx
```

**YAML Example**:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
 name: nginx-deployment
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
      image: nginx:1.25
      ports:
       - containerPort: 80
```

---

### 🧠 StatefulSet

**Definition**: Like a Deployment, but designed for **stateful applications**. It maintains a unique identity and persistent volume for each pod.

**Use Cases**:

- Databases (MySQL, MongoDB)
- Queues (Kafka, RabbitMQ)

**Key `kubectl` Commands**:

```bash
kubectl get statefulsets
kubectl describe statefulset mysql
kubectl delete statefulset mysql
```

**YAML Example**:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
 name: mysql
spec:
 serviceName: mysql
 replicas: 1
 selector:
  matchLabels:
   app: mysql
 template:
  metadata:
   labels:
    app: mysql
  spec:
   containers:
    - name: mysql
      image: mysql:8.0
      ports:
       - containerPort: 3306
      env:
       - name: MYSQL_ROOT_PASSWORD
         value: rootpass
 volumeClaimTemplates:
  - metadata:
     name: mysql-pv
    spec:
     accessModes: ["ReadWriteOnce"]
     resources:
      requests:
       storage: 10Gi
```

---

### 🔧 Service

**Definition**: Exposes a set of pods as a network service. Kubernetes supports multiple types of services depending on the networking goal.

#### 🔹 Types of Services:

1. **ClusterIP** _(default)_

   - Internal communication only.
   - Common for intra-cluster services.

   **Example**:

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
    name: auth-service
   spec:
    selector:
     app: auth
    ports:
     - protocol: TCP
       port: 80
       targetPort: 8080
    type: ClusterIP
   ```

2. **NodePort**

   - Exposes service on `<NodeIP>:<NodePort>` (30000–32767).
   - Used for development/testing clusters.

   **Example**:

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
    name: ui-service
   spec:
    selector:
     app: ui
    ports:
     - port: 80
       targetPort: 3000
       nodePort: 30080
    type: NodePort
   ```

3. **LoadBalancer**

   - Provisions external IP via cloud provider (e.g. AWS, GCP).
   - Recommended for production/public endpoints.

   **Example**:

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
    name: web-service
   spec:
    selector:
     app: web
    ports:
     - port: 80
       targetPort: 80
    type: LoadBalancer
   ```

4. **ExternalName**

   - Maps service to an external DNS name.
   - No selector; relies on DNS resolution.

   **Example**:

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
    name: external-google
   spec:
    type: ExternalName
    externalName: google.com
   ```

**Key `kubectl` Commands**:

```bash
kubectl get services
kubectl describe service auth-service
kubectl expose deployment nginx --type=NodePort --port=80
kubectl delete service ui-service
```

---

### 📦 ConfigMap

**Definition**: Stores non-sensitive configuration as key-value pairs. Used for environment configs and app settings.

**Use Cases**:

- Decoupling config from image
- Loading settings into environment variables or files

**YAML Example**:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: app-config
data:
 APP_MODE: production
 LOG_LEVEL: debug
```

**Key `kubectl` Commands**:

```bash
kubectl create configmap app-config --from-literal=APP_MODE=production
kubectl get configmaps
kubectl describe configmap app-config
kubectl delete configmap app-config
```

---

### 🔒 Secret

**Definition**: Stores sensitive data such as API keys and passwords.

**Use Cases**:

- Injecting DB credentials
- TLS certificates
- Service tokens

**YAML Example**:

```yaml
apiVersion: v1
kind: Secret
metadata:
 name: mysql-secret
type: Opaque
data:
 username: d2VhdGhlcl9hcHA= # base64 of 'weather_app'
 password: cGFzc3dvcmQ= # base64 of 'password'
```

**Key `kubectl` Commands**:

```bash
kubectl create secret generic mysql-secret --from-literal=username=weather_app --from-literal=password=password
kubectl get secrets
kubectl describe secret mysql-secret
kubectl delete secret mysql-secret
```

---

### 📶 Ingress

**Definition**: Manages external access to services via HTTP(S). Requires an ingress controller (e.g., NGINX).

**Use Cases**:

- Routing HTTP paths/domains
- TLS termination
- Central entry point for web apps

**YAML Example**:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
 name: ui-ingress
 annotations:
  nginx.ingress.kubernetes.io/rewrite-target: /
spec:
 tls:
  - hosts:
     - weatherapp.local
    secretName: weatherapp-ui-tls
 rules:
  - host: weatherapp.local
    http:
     paths:
      - path: /
        pathType: Prefix
        backend:
         service:
          name: ui-service
          port:
           number: 80
```

**Key `kubectl` Commands**:

```bash
kubectl get ingress
kubectl describe ingress ui-ingress
kubectl delete ingress ui-ingress
```

---

### 🧪 Job

**Definition**: A controller that runs one-off tasks to completion (e.g., database migrations, backups).

**Use Cases**:

- Batch processing
- Data migrations
- Initialization tasks

**YAML Example**:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
 name: db-migration
spec:
 template:
  spec:
   containers:
    - name: migrate
      image: busybox
      command: ["sh", "-c", "echo Running migration... && sleep 10"]
   restartPolicy: Never
 backoffLimit: 3
```

**Key `kubectl` Commands**:

```bash
kubectl create -f job.yaml
kubectl get jobs
kubectl describe job db-migration
kubectl delete job db-migration
```

---

### ⏰ CronJob

**Definition**: Schedules Jobs to run periodically using cron syntax.

**Use Cases**:

- Daily reports
- Scheduled backups
- Cache refreshes

**YAML Example**:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
 name: cleanup
spec:
 schedule: "*/5 * * * *" # every 5 minutes
 jobTemplate:
  spec:
   template:
    spec:
     containers:
      - name: cleanup
        image: busybox
        command: ["sh", "-c", "echo Cleaning temp files..."]
     restartPolicy: OnFailure
```

**Key `kubectl` Commands**:

```bash
kubectl create -f cronjob.yaml
kubectl get cronjobs
kubectl describe cronjob cleanup
kubectl delete cronjob cleanup
```

---

### 💾 PersistentVolume & PersistentVolumeClaim

**Definition**:

- **PersistentVolume (PV)**: A cluster resource representing storage.
- **PersistentVolumeClaim (PVC)**: A request for storage by a pod.

**Use Cases**:

- Database storage
- File uploads
- Data that must survive pod restarts

**YAML Example (PVC + PV)**:

```yaml
# pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-local
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data

# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

**Key `kubectl` Commands**:

```bash
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl get pv,pvc
kubectl describe pvc app-pvc
kubectl delete pvc app-pvc
```

---

### 📈 HorizontalPodAutoscaler (HPA)

**Definition**: Automatically adjusts the number of pod replicas based on CPU or memory usage.

**Use Cases**:

- Scale web servers under load
- Optimize resource usage

**YAML Example**:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
 name: nginx-hpa
spec:
 scaleTargetRef:
  apiVersion: apps/v1
  kind: Deployment
  name: nginx-deployment
 minReplicas: 2
 maxReplicas: 10
 metrics:
  - type: Resource
    resource:
     name: cpu
     target:
      type: Utilization
      averageUtilization: 50
```

**Key `kubectl` Commands**:

```bash
kubectl autoscale deployment nginx-deployment --cpu-percent=50 --min=2 --max=10
kubectl get hpa
kubectl describe hpa nginx-hpa
kubectl delete hpa nginx-hpa
```

---

### 🔐 RBAC (Role-Based Access Control)

**Definition**: Controls who can access Kubernetes resources and what actions they can perform.

**Use Cases**:

- Securing access per namespace
- Assigning developer/admin roles
- Granting external tools limited access

**YAML Example**:

```yaml
# role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: weather-app
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]

# rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: weather-app
subjects:
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**Key `kubectl` Commands**:

```bash
kubectl apply -f role.yaml
kubectl apply -f rolebinding.yaml
kubectl get roles -n weather-app
kubectl describe rolebinding read-pods -n weather-app
```

---

## 📁 Project Structure

```text
kubernetes/
├── authentication/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── mysql/
│       ├── headless-service.yaml
│       ├── init-job.yaml
│       └── statefulset.yaml
├── weather/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── secret.yaml
├── ui/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── tls.crt
│   └── tls.key
```

---

## 🎓 Kubernetes Concepts

### Deployments vs StatefulSets

| Feature         | Deployment          | StatefulSet              |
| --------------- | ------------------- | ------------------------ |
| Pod Identity    | Anonymous           | Unique (stable hostname) |
| Use Case        | Stateless apps      | Databases, queues        |
| Volume Handling | Shared or ephemeral | Persistent per pod       |

**Examples**:

- `authentication/deployment.yaml` → stateless login service
- `authentication/mysql/statefulset.yaml` → stateful MySQL database

---

## 🚀 Getting Started

### 1. Create Kind Cluster

```bash
kind create cluster --name kubernetes-master --config kind-config.yaml
```

### 2. Deploy Ingress

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait -n ingress-nginx --for=condition=ready pod -l app.kubernetes.io/component=controller --timeout=90s
```

### 3. Add Host Entry

Add the following line to `/etc/hosts` (Linux/macOS) or `C:\Windows\System32\drivers\etc\hosts`:

```bash
127.0.0.1 weatherapp.local
```

---

## 🏗️ Project Implementation

### 🔐 Step 1: Secrets & Namespace

```bash
kubectl create namespace weather-app

kubectl create secret generic mysql-secret \
  --from-literal=username=weather_app \
  --from-literal=password=your-password \
  --from-literal=root-password=your-root-password \
  --from-literal=secret-key=jwt-secret \
  -n weather-app

kubectl create secret generic weather \
  --from-literal=apikey=your-weather-api-key \
  -n weather-app
```

---

### 🧩 Step 2: Apply Components

```bash
# MySQL (DB & Init)
kubectl apply -f kubernetes/authentication/mysql/ -n weather-app

# Auth Service
kubectl apply -f kubernetes/authentication/ -n weather-app

# Weather Service
kubectl apply -f kubernetes/weather/ -n weather-app

# UI Service
kubectl apply -f kubernetes/ui/ -n weather-app
```

---

### 🌐 Step 3: Apply Ingress

```bash
kubectl apply -f kubernetes/ui/ingress.yaml -n weather-app
```

Ensure TLS files are created from your certificate:

```bash
kubectl create secret tls weatherapp-ui-tls \
  --cert=tls.crt \
  --key=tls.key \
  -n weather-app
```

---

## 🩺 Monitoring & Scaling

### 🔍 View Status

```bash
kubectl get all -n weather-app
kubectl describe service weatherapp-auth -n weather-app
kubectl get ingress -n weather-app
```

### 📦 Logs

```bash
kubectl logs -f deployment/weatherapp-ui -n weather-app
kubectl logs -f deployment/weatherapp-auth -n weather-app
kubectl logs -f deployment/weatherapp-weather -n weather-app
kubectl logs -f statefulset/mysql -n weather-app
```

### 📈 Scale Pods

```bash
kubectl scale deployment weatherapp-ui --replicas=3 -n weather-app
kubectl scale deployment weatherapp-auth --replicas=3 -n weather-app
kubectl scale deployment weatherapp-weather --replicas=3 -n weather-app
```

### 🛠 MySQL Management

```bash
# Enter container
kubectl exec -it mysql-0 -n weather-app -- mysql -u root -p

# Backup
kubectl exec -it mysql-0 -n weather-app -- mysqldump -u root -p weather_app > backup.sql
```

---

## 💡 Best Practices

- Use `livenessProbe` and `readinessProbe` for resilience
- Define `requests` and `limits` for each container
- Separate Secrets from ConfigMaps
- Use Ingress for unified routing
- Enable RBAC for service permissions

---

## 🤝 Contributing

1. Fork this repo
2. Create a new branch: `git checkout -b feature/YourFeature`
3. Commit your changes: `git commit -m "Add Feature"`
4. Push to GitHub: `git push origin feature/YourFeature`
5. Create a Pull Request

---

## 📄 License

Licensed under [MIT License](https://opensource.org/licenses/MIT)
