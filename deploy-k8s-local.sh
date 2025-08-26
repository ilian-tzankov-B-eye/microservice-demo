#!/bin/bash

# Kubernetes deployment script for local development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Deploying Microservices to Local Kubernetes${NC}"
echo "============================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Check if Kubernetes cluster is accessible
echo -e "\n${YELLOW}🔍 Checking Kubernetes cluster...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    echo -e "${YELLOW}💡 Please ensure you have a Kubernetes cluster running:${NC}"
    echo "   • For local development: minikube start"
    echo "   • For Docker Desktop: Enable Kubernetes in settings"
    echo "   • For cloud clusters: Configure kubectl with your cluster credentials"
    echo -e "\n${BLUE}📚 Quick start options:${NC}"
    echo "   1. Install minikube: https://minikube.sigs.k8s.io/docs/start/"
    echo "   2. Use Docker Desktop Kubernetes"
    echo "   3. Use kind: https://kind.sigs.k8s.io/"
    echo -e "\n${YELLOW}🔄 After starting your cluster, run this script again.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Kubernetes cluster is accessible${NC}"

# Build images if they don't exist
echo -e "\n${YELLOW}🐳 Checking Docker images...${NC}"
if ! docker images | grep -q "microservices-demo/service1"; then
    echo -e "${YELLOW}⚠️  Images not found. Building them...${NC}"
    ./build-images.sh
fi

# Prepare images for Kubernetes
echo -e "\n${YELLOW}🐳 Preparing Docker images for Kubernetes...${NC}"
if [ -f "./prepare-k8s-images.sh" ]; then
    ./prepare-k8s-images.sh
else
    echo -e "${YELLOW}⚠️  Image preparation script not found. Make sure images are available.${NC}"
fi

# Create namespace
echo -e "\n${YELLOW}📁 Creating namespace...${NC}"
if kubectl apply -f k8s/namespace.yaml --validate=false; then
    echo -e "${GREEN}✅ Namespace created${NC}"
else
    echo -e "${YELLOW}⚠️  Namespace creation failed, continuing anyway...${NC}"
fi

# Deploy Service 1 (local)
echo -e "\n${YELLOW}📦 Deploying Service 1 (User Management)...${NC}"
if kubectl apply -f k8s/service1-deployment-local.yaml --validate=false; then
    echo -e "${GREEN}✅ Service 1 deployed${NC}"
else
    echo -e "${RED}❌ Service 1 deployment failed${NC}"
    exit 1
fi

# Deploy Service 2 (local)
echo -e "\n${YELLOW}📦 Deploying Service 2 (Data Processing)...${NC}"
if kubectl apply -f k8s/service2-deployment-local.yaml --validate=false; then
    echo -e "${GREEN}✅ Service 2 deployed${NC}"
else
    echo -e "${RED}❌ Service 2 deployment failed${NC}"
    exit 1
fi

# Deploy Test Dashboard (local)
echo -e "\n${YELLOW}📦 Deploying Test Dashboard...${NC}"
if kubectl apply -f k8s/webapp-deployment-local.yaml --validate=false; then
    echo -e "${GREEN}✅ Test Dashboard deployed${NC}"
else
    echo -e "${RED}❌ Test Dashboard deployment failed${NC}"
    exit 1
fi

echo -e "\n${GREEN}🎉 All services deployed successfully!${NC}"

# Wait for pods to be ready
echo -e "\n${YELLOW}⏳ Waiting for pods to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=service1-user-management -n microservices-demo --timeout=300s
kubectl wait --for=condition=ready pod -l app=service2-data-processing -n microservices-demo --timeout=300s
kubectl wait --for=condition=ready pod -l app=test-dashboard -n microservices-demo --timeout=300s

echo -e "\n${GREEN}✅ All pods are ready!${NC}"

# Show deployment status
echo -e "\n${BLUE}📋 Deployment Status:${NC}"
kubectl get pods -n microservices-demo

echo -e "\n${BLUE}🌐 Services:${NC}"
kubectl get svc -n microservices-demo

echo -e "\n${YELLOW}🔗 Access Information:${NC}"
echo "  • Test Dashboard: kubectl port-forward svc/test-dashboard 8080:80 -n microservices-demo"
echo "  • Service 1 API: kubectl port-forward svc/service1-user-management 8000:8000 -n microservices-demo"
echo "  • Service 2 API: kubectl port-forward svc/service2-data-processing 8001:8001 -n microservices-demo"

echo -e "\n${GREEN}🎯 Dashboard will be available at: http://localhost:8080${NC}"

