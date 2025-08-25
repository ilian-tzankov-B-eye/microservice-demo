# FastAPI Microservices Example

This project demonstrates two FastAPI services that communicate with each other, plus a web dashboard for testing and monitoring.

## Services Overview

### Service 1 (User Management Service) - Port 8000
- **Purpose**: Manages user data and provides CRUD operations
- **Features**:
  - Create, read, and delete users
  - Store user information (name, email, age)
  - Automatically sends user data to Service 2 for processing
  - Retrieves processed data from Service 2

### Service 2 (Data Processing Service) - Port 8001
- **Purpose**: Processes user data and provides analytics
- **Features**:
  - Processes user data (calculates name length, email domain, age categories, etc.)
  - Provides analytics and statistics
  - Stores processed user data
  - Cross-service communication testing

### Test Dashboard (Web Application) - Port 8002
- **Purpose**: Web interface for testing and monitoring the microservices
- **Features**:
  - Real-time service health monitoring
  - Interactive test execution
  - Visual results display
  - User data and analytics viewing
  - Modern responsive UI

## Installation

1. Install dependencies:
```bash
pip install -r requirements.txt
```

## Running the Services

### Option 1: Run all services with startup script (Recommended)

```bash
cd example
python start_services.py
```

This will start all three services and display their URLs. Press Ctrl+C to stop all services.

### Option 2: Run in separate terminals

**Terminal 1 - Service 1:**
```bash
cd example
python service1.py
```

**Terminal 2 - Service 2:**
```bash
cd example
python service2.py
```

**Terminal 3 - Test Dashboard (Optional):**
```bash
cd example
python test_web_app.py
```

### Option 2: Run with uvicorn directly

**Terminal 1 - Service 1:**
```bash
cd example
uvicorn service1:app --host 0.0.0.0 --port 8000 --reload
```

**Terminal 2 - Service 2:**
```bash
cd example
uvicorn service2:app --host 0.0.0.0 --port 8001 --reload
```

**Terminal 3 - Test Dashboard (Optional):**
```bash
cd example
uvicorn test_web_app:app --host 0.0.0.0 --port 8002 --reload
```

## API Endpoints

### Service 1 (http://localhost:8000)

- `GET /` - Service status
- `GET /health` - Health check
- `POST /users` - Create a new user
- `GET /users` - Get all users
- `GET /users/{user_id}` - Get specific user
- `GET /users/{user_id}/processed` - Get user with processed data from Service 2
- `DELETE /users/{user_id}` - Delete user

### Service 2 (http://localhost:8001)

- `GET /` - Service status
- `GET /health` - Health check
- `POST /process-user` - Process user data
- `GET /processed-users/{user_id}` - Get processed user data
- `GET /processed-users` - Get all processed users
- `DELETE /processed-users/{user_id}` - Delete processed user data
- `GET /analytics` - Get analytics summary
- `GET /cross-service-test` - Test communication with Service 1
- `POST /batch-process` - Process all users from Service 1

### Test Dashboard (http://localhost:8002)

- `GET /` - Main dashboard page
- `POST /api/run-tests` - Run all tests
- `GET /api/health` - Quick health check
- `GET /api/users` - Get all users from Service 1
- `GET /api/analytics` - Get analytics from Service 2

## Testing the Services

### 1. Create a user (Service 1)
```bash
curl -X POST "http://localhost:8000/users" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "John Doe",
       "email": "john@example.com",
       "age": 30
     }'
```

### 2. Get all users (Service 1)
```bash
curl "http://localhost:8000/users"
```

### 3. Get processed user data (Service 1)
```bash
curl "http://localhost:8000/users/1/processed"
```

### 4. Get analytics (Service 2)
```bash
curl "http://localhost:8001/analytics"
```

### 5. Test cross-service communication (Service 2)
```bash
curl "http://localhost:8001/cross-service-test"
```

## Interactive API Documentation

Once the services are running, you can access the interactive API documentation:

- **Service 1**: http://localhost:8000/docs
- **Service 2**: http://localhost:8001/docs
- **Test Dashboard**: http://localhost:8002 (Web interface)

## Example Workflow

1. Start both services (and optionally the test dashboard)
2. Create a user via Service 1 (automatically triggers processing in Service 2)
3. View the user's processed data via Service 1
4. Check analytics via Service 2
5. Test cross-service communication
6. Use the web dashboard for interactive testing and monitoring

## Architecture

```
┌─────────────────┐    HTTP Requests    ┌─────────────────┐
│   Service 1     │◄──────────────────►│   Service 2     │
│ (Port 8000)     │                     │ (Port 8001)     │
│                 │                     │                 │
│ - User CRUD     │                     │ - Data Processing│
│ - User Storage  │                     │ - Analytics     │
│ - Service2 Sync │                     │ - Cross-service │
└─────────────────┘                     └─────────────────┘
         ▲                                       ▲
         │                                       │
         │ HTTP Requests                         │
         │                                       │
    ┌─────────────────┐                         │
    │  Test Dashboard │─────────────────────────┘
    │  (Port 8002)    │
    │                 │
    │ - Web Interface │
    │ - Test Runner   │
    │ - Monitoring    │
    └─────────────────┘
```

## Error Handling

Both services include comprehensive error handling:
- HTTP status codes for different error scenarios
- Graceful handling of service communication failures
- Input validation using Pydantic models
- Proper error messages and logging

## 🐳 Docker & Kubernetes Deployment

The services can be deployed using Docker and Kubernetes:

### Quick Start
```bash
# Build Docker images
./build-images.sh

# Deploy to Kubernetes
./deploy-k8s.sh
```

### Detailed Instructions
See [KUBERNETES.md](KUBERNETES.md) for complete deployment guide.

### Docker Images
- `microservices-demo/service1:latest` - User Management Service
- `microservices-demo/service2:latest` - Data Processing Service  
- `microservices-demo/webapp:latest` - Test Dashboard
