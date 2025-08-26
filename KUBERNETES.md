# Kubernetes Deployment Guide

This guide explains how to deploy the FastAPI microservices to Kubernetes.

## 🏗️ Architecture

```
┌──────────────────────────────────────────────┐
│             Kubernetes Cluster               │
├──────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐  │
│  │   Service 1     │    │   Service 2     │  │
│  │ (User Mgmt)     │◄──►│ (Data Proc)     │  │
│  │ Port: 8000      │    │ Port: 8001      │  │
│  └─────────────────┘    └─────────────────┘  │
│           ▲                       ▲          │
│           │                       │          │
│  ┌────────────────────────────────────────┐  │
│  │           Test Dashboard               │  │
│  │         (Web Interface)                │  │
│  │           Port: 8002                   │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

## 📋 Prerequisites

- Docker installed and running
- Kubernetes cluster (local or cloud)
- kubectl configured to access your cluster

See README.md for information on how to set this up.

### 🚀 Quick Setup for Local Development

If you don't have a Kubernetes cluster set up, use the setup script:

```bash
cd example
./setup-k8s-local.sh
```

This script will:
- Check for Docker Desktop, Minikube, or Kind
- Help you enable Kubernetes in Docker Desktop
- Start a local cluster automatically
- Provide installation instructions if needed

## 🐳 Building Docker Images

### Option 1: Build All Images at Once
```bash
cd example
./build-images.sh
```

### Option 2: Build Images Individually
```bash
# Build Service 1
docker build -f Dockerfile.service1 -t microservices-demo/service1:latest .

# Build Service 2
docker build -f Dockerfile.service2 -t microservices-demo/service2:latest .

# Build Web Dashboard
docker build -f Dockerfile.webapp -t microservices-demo/webapp:latest .
```

## 📦 Preparing Images for Kubernetes

After building images, prepare them for your Kubernetes cluster:

```bash
./prepare-k8s-images.sh
```

This script will:
- Detect your Kubernetes cluster type (Minikube, Kind, Docker Desktop)
- Load images into the appropriate cluster
- Handle different image loading methods for each cluster type

## 🚀 Deploying to Kubernetes

### Option 1: Standard Deployment
```bash
cd example
./deploy-k8s.sh
```

### Option 2: Deploy Manually
```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy services (choose local or standard)
kubectl apply -f k8s/service1-deployment-local.yaml  # Local development
kubectl apply -f k8s/service2-deployment-local.yaml  # Local development
kubectl apply -f k8s/webapp-deployment-local.yaml    # Local development

# OR use standard deployments
kubectl apply -f k8s/service1-deployment.yaml
kubectl apply -f k8s/service2-deployment.yaml
kubectl apply -f k8s/webapp-deployment.yaml
```

## 📊 Monitoring the Deployment

### Check Pod Status
```bash
kubectl get pods -n microservices-demo
```

### Check Services
```bash
kubectl get svc -n microservices-demo
```

### View Logs
```bash
# Service 1 logs
kubectl logs -f deployment/service1-user-management -n microservices-demo

# Service 2 logs
kubectl logs -f deployment/service2-data-processing -n microservices-demo

# Dashboard logs
kubectl logs -f deployment/test-dashboard -n microservices-demo
```

## 🌐 Accessing the Services

### Port Forwarding (Recommended for Development)
```bash
# Access Test Dashboard
kubectl port-forward svc/test-dashboard 8080:80 -n microservices-demo

# Access Service 1 API
kubectl port-forward svc/service1-user-management 8000:8000 -n microservices-demo

# Access Service 2 API
kubectl port-forward svc/service2-data-processing 8001:8001 -n microservices-demo
```

### Access URLs
- **Test Dashboard**: http://localhost:8080
- **Service 1 API**: http://localhost:8000
- **Service 2 API**: http://localhost:8001
- **Service 1 Docs**: http://localhost:8000/docs
- **Service 2 Docs**: http://localhost:8001/docs

## 🔧 Configuration

### Environment Variables

The services use environment variables for configuration:

| Service | Variable | Default | Kubernetes Value | Description |
|---------|----------|---------|------------------|-------------|
| Service 1 | `SERVICE2_URL` | `http://localhost:8001` | `http://service2-data-processing:8001` | URL for Service 2 |
| Service 1 | `SERVICE2_TIMEOUT` | `10` | `10` | Timeout for Service 2 calls |
| Service 2 | `SERVICE1_URL` | `http://localhost:8000` | `http://service1-user-management:8000` | URL for Service 1 |
| Service 2 | `SERVICE1_TIMEOUT` | `10` | `10` | Timeout for Service 1 calls |
| Dashboard | `SERVICE1_URL` | `http://localhost:8000` | `http://service1-user-management:8000` | URL for Service 1 |
| Dashboard | `SERVICE2_URL` | `http://localhost:8001` | `http://service2-data-processing:8001` | URL for Service 2 |
| Dashboard | `SERVICE_TIMEOUT` | `10` | `10` | Timeout for service calls |

### Resource Limits

Each service has resource limits configured:

- **CPU**: 100m request, 200m limit
- **Memory**: 128Mi request, 256Mi limit

## 🏥 Health Checks

All services include health checks:

- **Liveness Probe**: Checks if the service is alive
- **Readiness Probe**: Checks if the service is ready to receive traffic
- **Health Endpoint**: `/health` for services, `/api/health` for dashboard

## 🧪 Testing URL Configuration

Before deploying to Kubernetes, you can test the URL configuration:

```bash
# Test environment variables and connectivity
python test-k8s-urls.py
```

This script will:
- Verify environment variables are set correctly
- Test service connectivity
- Check if URLs are configured for Kubernetes

## 🔍 Troubleshooting

### Common Issues

1. **Kubernetes Cluster Not Running**
   ```bash
   # Error: "connection refused" or "failed to download openapi"
   ./setup-k8s-local.sh
   ```

2. **Images Not Found**
   ```bash
   # Check if images exist
   docker images | grep microservices-demo
   
   # Rebuild if needed
   ./build-images.sh
   ```

3. **Images Not Pullable**
   ```bash
   # Error: "ErrImagePull" or "ImagePullBackOff"
   ./prepare-k8s-images.sh
   ```

4. **Pods Not Starting**
   ```bash
   # Check pod events
   kubectl describe pod <pod-name> -n microservices-demo
   
   # Check logs
   kubectl logs <pod-name> -n microservices-demo
   ```

5. **Services Not Communicating**
   ```bash
   # Check service endpoints
   kubectl get endpoints -n microservices-demo
   
   # Test connectivity
   kubectl exec -it <pod-name> -n microservices-demo -- curl <service-url>
   ```

6. **Validation Errors**
   ```bash
   # If you get validation errors, use --validate=false
   kubectl apply -f k8s/ --validate=false
   ```

### Scaling Services

```bash
# Scale Service 1 to 3 replicas
kubectl scale deployment service1-user-management --replicas=3 -n microservices-demo

# Scale Service 2 to 2 replicas
kubectl scale deployment service2-data-processing --replicas=2 -n microservices-demo
```

## 🧹 Cleanup

### Option 1: Interactive Cleanup
```bash
./cleanup-k8s.sh
```
This script will:
- Delete all deployments, services, and pods
- Delete the namespace
- Optionally clean up Docker images
- Provide detailed feedback

### Option 2: Quick Cleanup
```bash
./cleanup-k8s-quick.sh
```
This script will:
- Quickly delete the namespace (removes all resources)
- No user interaction required
- Fast cleanup for automation

### Option 3: Manual Cleanup
```bash
# Delete namespace (removes all resources)
kubectl delete namespace microservices-demo

# Remove Docker images
docker rmi microservices-demo/service1:latest
docker rmi microservices-demo/service2:latest
docker rmi microservices-demo/webapp:latest
```

## 📁 File Structure

```
example/
├── Dockerfile.service1          # Service 1 Dockerfile
├── Dockerfile.service2          # Service 2 Dockerfile
├── Dockerfile.webapp            # Dashboard Dockerfile
├── build-images.sh              # Build script
├── deploy-k8s.sh                # Deployment script
├── k8s/
│   ├── namespace.yaml           # Kubernetes namespace
│   ├── service1-deployment.yaml # Service 1 deployment
│   ├── service2-deployment.yaml # Service 2 deployment
│   └── webapp-deployment.yaml   # Dashboard deployment
└── KUBERNETES.md                # This file
```

## 🎯 Next Steps

1. **Production Deployment**: Add ingress controllers and SSL certificates
2. **Monitoring**: Integrate with Prometheus and Grafana
3. **Logging**: Add centralized logging with ELK stack
4. **CI/CD**: Set up automated deployment pipelines
5. **Security**: Add network policies and RBAC
