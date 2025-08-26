#!/usr/bin/env python3
"""
Test script to demonstrate the interaction between Service 1 and Service 2
"""

import asyncio
import httpx
import json
from typing import Dict, Any

# Service URLs
SERVICE1_URL = "http://localhost:8000"
SERVICE2_URL = "http://localhost:8001"

async def test_services():
    """Test the interaction between the two services"""
    
    print("🚀 Testing FastAPI Microservices Communication")
    print("=" * 50)
    
    async with httpx.AsyncClient() as client:
        
        # Test 1: Check if services are running
        print("\n1. Checking service health...")
        try:
            response1 = await client.get(f"{SERVICE1_URL}/health")
            response2 = await client.get(f"{SERVICE2_URL}/health")
            
            print(f"✅ Service 1: {response1.json()}")
            print(f"✅ Service 2: {response2.json()}")
        except Exception as e:
            print(f"❌ Services not running: {e}")
            return
        
        # Test 2: Create users in Service 1
        print("\n2. Creating users in Service 1...")
        users_data = [
            {"name": "Alice Johnson", "email": "alice@example.com", "age": 25},
            {"name": "Bob Smith", "email": "bob@company.com", "age": 35},
            {"name": "Carol Davis", "email": "carol@university.edu", "age": 45}
        ]
        
        created_users = []
        for user_data in users_data:
            try:
                response = await client.post(f"{SERVICE1_URL}/users", json=user_data)
                if response.status_code == 200:
                    user = response.json()
                    created_users.append(user)
                    print(f"✅ Created user: {user['name']} (ID: {user['id']})")
                else:
                    print(f"❌ Failed to create user: {response.text}")
            except Exception as e:
                print(f"❌ Error creating user: {e}")
        
        # Test 3: Get all users from Service 1
        print("\n3. Getting all users from Service 1...")
        try:
            response = await client.get(f"{SERVICE1_URL}/users")
            if response.status_code == 200:
                users = response.json()
                print(f"✅ Found {len(users)} users in Service 1")
                for user in users:
                    print(f"   - {user['name']} ({user['email']}) - Age: {user['age']}")
            else:
                print(f"❌ Failed to get users: {response.text}")
        except Exception as e:
            print(f"❌ Error getting users: {e}")
        
        # Test 4: Get processed user data (Service 1 -> Service 2)
        print("\n4. Getting processed user data...")
        for user in created_users:
            try:
                response = await client.get(f"{SERVICE1_URL}/users/{user['id']}/processed")
                if response.status_code == 200:
                    processed_data = response.json()
                    print(f"✅ User {user['name']} processed data:")
                    print(f"   - Service 2 status: {processed_data['service2_status']}")
                    if processed_data['processed_data']:
                        print(f"   - Age category: {processed_data['processed_data'].get('age_category', 'N/A')}")
                        print(f"   - Email domain: {processed_data['processed_data'].get('email_domain', 'N/A')}")
                else:
                    print(f"❌ Failed to get processed data for user {user['name']}: {response.text}")
            except Exception as e:
                print(f"❌ Error getting processed data: {e}")
        
        # Test 5: Get analytics from Service 2
        print("\n5. Getting analytics from Service 2...")
        try:
            response = await client.get(f"{SERVICE2_URL}/analytics")
            if response.status_code == 200:
                analytics = response.json()
                print(f"✅ Analytics summary:")
                print(f"   - Total users: {analytics['total_users']}")
                print(f"   - Average age: {analytics['average_age']}")
                print(f"   - Age distribution: {analytics['age_distribution']}")
            else:
                print(f"❌ Failed to get analytics: {response.text}")
        except Exception as e:
            print(f"❌ Error getting analytics: {e}")
        
        # Test 6: Test cross-service communication
        print("\n6. Testing cross-service communication...")
        try:
            response = await client.get(f"{SERVICE2_URL}/cross-service-test")
            if response.status_code == 200:
                test_results = response.json()
                print(f"✅ Cross-service test results:")
                print(f"   - Service 1 health: {test_results['cross_service_test']['service1_health']['status']}")
                print(f"   - Service 1 users count: {test_results['cross_service_test']['service1_users']['count']}")
                print(f"   - Service 2 processed users: {test_results['processed_users_count']}")
            else:
                print(f"❌ Failed to test cross-service communication: {response.text}")
        except Exception as e:
            print(f"❌ Error testing cross-service communication: {e}")
        
        # Test 7: Get all processed users from Service 2
        print("\n7. Getting all processed users from Service 2...")
        try:
            response = await client.get(f"{SERVICE2_URL}/processed-users")
            if response.status_code == 200:
                processed_users = response.json()
                print(f"✅ Found {len(processed_users)} processed users in Service 2")
                for user_data in processed_users:
                    print(f"   - User ID {user_data['user_id']}: {user_data['processed_data']['age_category']} category")
            else:
                print(f"❌ Failed to get processed users: {response.text}")
        except Exception as e:
            print(f"❌ Error getting processed users: {e}")
    
    print("\n" + "=" * 50)
    print("🎉 Testing completed!")
    print("\nYou can also visit:")
    print(f"   - Service 1 docs: {SERVICE1_URL}/docs")
    print(f"   - Service 2 docs: {SERVICE2_URL}/docs")

if __name__ == "__main__":
    asyncio.run(test_services())

