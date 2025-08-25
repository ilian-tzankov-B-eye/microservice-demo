#!/bin/bash

# Kubernetes deployment script for microservices

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Deploying Microservices to Kubernetes${NC}"
echo "============================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Create namespace
echo -e "\n${YELLOW}📁 Creating namespace...${NC}"
kubectl apply -f k8s/namespace.yaml
echo -e "${GREEN}✅ Namespace created${NC}"

# Deploy Service 1
echo -e "\n${YELLOW}📦 Deploying Service 1 (User Management)...${NC}"
kubectl apply -f k8s/service1-deployment.yaml
echo -e "${GREEN}✅ Service 1 deployed${NC}"

# Deploy Service 2
echo -e "\n${YELLOW}📦 Deploying Service 2 (Data Processing)...${NC}"
kubectl apply -f k8s/service2-deployment.yaml
echo -e "${GREEN}✅ Service 2 deployed${NC}"

# Deploy Test Dashboard
echo -e "\n${YELLOW}📦 Deploying Test Dashboard...${NC}"
kubectl apply -f k8s/webapp-deployment.yaml
echo -e "${GREEN}✅ Test Dashboard deployed${NC}"

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
