#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

NAMESPACE="microservices-demo"

echo -e "${BLUE}🚀 Deploying Debug Services to Kubernetes${NC}"
echo "=============================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Check if Kubernetes cluster is accessible
echo -e "${YELLOW}🔍 Checking Kubernetes cluster...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    echo -e "${YELLOW}💡 Please ensure you have a Kubernetes cluster running${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Kubernetes cluster is accessible${NC}"

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo -e "${YELLOW}📦 Creating namespace: $NAMESPACE${NC}"
    kubectl create namespace "$NAMESPACE"
fi

# Prepare images for Kubernetes (load into cluster if needed)
echo -e "${YELLOW}📦 Preparing debug images for Kubernetes...${NC}"
./prepare-k8s-images-debug.sh

# Deploy debug services
echo -e "\n${YELLOW}🚀 Deploying debug services...${NC}"

# Deploy Service 1 Debug
echo -e "${BLUE}📋 Deploying Service 1 Debug...${NC}"
if kubectl apply -f k8s/service1-deployment-debug.yaml --validate=false; then
    echo -e "${GREEN}✅ Service 1 Debug deployed successfully${NC}"
else
    echo -e "${RED}❌ Failed to deploy Service 1 Debug${NC}"
    exit 1
fi

# Deploy Service 2 Debug
echo -e "${BLUE}📋 Deploying Service 2 Debug...${NC}"
if kubectl apply -f k8s/service2-deployment-debug.yaml --validate=false; then
    echo -e "${GREEN}✅ Service 2 Debug deployed successfully${NC}"
else
    echo -e "${RED}❌ Failed to deploy Service 2 Debug${NC}"
    exit 1
fi

# Deploy Webapp Debug
echo -e "${BLUE}📋 Deploying Webapp Debug...${NC}"
if kubectl apply -f k8s/webapp-deployment-debug.yaml --validate=false; then
    echo -e "${GREEN}✅ Webapp Debug deployed successfully${NC}"
else
    echo -e "${RED}❌ Failed to deploy Webapp Debug${NC}"
    exit 1
fi

# Wait for pods to be running (not ready, since they wait for debugger)
echo -e "\n${YELLOW}⏳ Waiting for debug pods to be running...${NC}"
kubectl wait --for=condition=ready pod -l app=service1-user-management-debug -n "$NAMESPACE" --timeout=60s || {
    echo -e "${YELLOW}⚠️  Service 1 pod is waiting for debugger connection${NC}"
    kubectl wait --for=condition=podScheduled pod -l app=service1-user-management-debug -n "$NAMESPACE" --timeout=60s
}
kubectl wait --for=condition=ready pod -l app=service2-data-processing-debug -n "$NAMESPACE" --timeout=60s || {
    echo -e "${YELLOW}⚠️  Service 2 pod is waiting for debugger connection${NC}"
    kubectl wait --for=condition=podScheduled pod -l app=service2-data-processing-debug -n "$NAMESPACE" --timeout=60s
}
kubectl wait --for=condition=ready pod -l app=test-dashboard-debug -n "$NAMESPACE" --timeout=60s || {
    echo -e "${YELLOW}⚠️  Webapp pod is waiting for debugger connection${NC}"
    kubectl wait --for=condition=podScheduled pod -l app=test-dashboard-debug -n "$NAMESPACE" --timeout=60s
}

# Show deployment status
echo -e "\n${BLUE}📊 Debug Deployment Status:${NC}"
kubectl get pods -n "$NAMESPACE" -l "app in (service1-user-management-debug,service2-data-processing-debug,test-dashboard-debug)"

# Show services
echo -e "\n${BLUE}🔌 Debug Services:${NC}"
kubectl get services -n "$NAMESPACE" -l "app in (service1-user-management-debug,service2-data-processing-debug,test-dashboard-debug)"

echo -e "\n${GREEN}🎉 Debug services deployed successfully!${NC}"
echo -e "\n${YELLOW}🔧 Debug Setup Instructions:${NC}"
echo "1. Set up port forwarding for debug ports:"
echo "   kubectl port-forward -n $NAMESPACE svc/service1-user-management-debug 8000:8000 5678:5678"
echo "   kubectl port-forward -n $NAMESPACE svc/service2-data-processing-debug 8001:8001 5679:5679"
echo "   kubectl port-forward -n $NAMESPACE svc/test-dashboard-debug 8002:8002 5680:5680"
echo ""
echo "2. Connect your debugger to:"
echo "   - Service 1: localhost:5678"
echo "   - Service 2: localhost:5679"
echo "   - Webapp: localhost:5680"
echo ""
echo "3. The services will wait for debugger connection before starting"
echo "   (This is why pods may show as 'Not Ready' until debugger connects)"
echo ""
echo "4. To access the services:"
echo "   - Service 1: http://localhost:8000"
echo "   - Service 2: http://localhost:8001"
echo "   - Webapp: http://localhost:8002"
