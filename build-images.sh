#!/bin/bash

# Build script for microservices Docker images

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Building Microservices Docker Images${NC}"
echo "=========================================="

for service in service1 service2 webapp; do
    echo -e "\n${YELLOW}📦 Building ${service}...${NC}"
    docker build -f Dockerfile.${service} -t microservices-demo/${service}:latest .
    echo -e "${GREEN}✅ ${service} image built successfully${NC}"
done

echo -e "\n${GREEN}🎉 All images built successfully!${NC}"
echo -e "\n${BLUE}📋 Built Images:${NC}"
echo "  • microservices-demo/service1:latest"
echo "  • microservices-demo/service2:latest"
echo "  • microservices-demo/webapp:latest"

echo -e "\n${YELLOW}🚀 Next steps:${NC}"
echo "  1. Deploy to Kubernetes:"
echo "     kubectl apply -f k8s/"
echo "  2. Check deployment status:"
echo "     kubectl get pods -n microservices-demo"
echo "  3. Access the dashboard:"
echo "     kubectl get svc -n microservices-demo"


