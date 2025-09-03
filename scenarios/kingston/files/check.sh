#!/bin/bash

# Kingston Scenario - Validation Script
# This script validates that the Docker optimization meets the requirements

# Configuration
BASE_IMAGE="simple-app:base"
OPTIMIZED_IMAGE="simple-app:optimized"
BASE_DOCKERFILE="Dockerfile.base" 
OPTIMIZED_DOCKERFILE="Dockerfile.optimized"
REQUIRED_IMPROVEMENT=10.0

# Function to measure build time silently
measure_build_time_silent() {
    local dockerfile=$1
    local image_name=$2
    
    # Clean build environment
    docker system prune -f &>/dev/null || true
    
    # Remove existing image
    docker rmi "$image_name" 2>/dev/null || true
    
    # Measure build time
    local start_time=$(date +%s.%N)
    
    if docker build -f "$dockerfile" -t "$image_name" . &>/dev/null; then
        local end_time=$(date +%s.%N)
        local build_time=$(echo "$end_time - $start_time" | bc -l)
        printf "%.6f" "$build_time"
        return 0
    else
        return 1
    fi
}

# Function to test container functionality
test_container_functionality() {
    local image_name=$1
    
    # Start container
    local container_id=$(docker run -d "$image_name" 2>/dev/null)
    if [[ -z "$container_id" ]]; then
        return 1
    fi
    
    # Wait for app to start
    sleep 3
    
    # Check if container is still running (basic health check)
    local is_running=$(docker ps -q --filter "id=$container_id" | wc -l)
    
    # Cleanup
    docker stop "$container_id" &>/dev/null
    docker rm "$container_id" &>/dev/null
    
    [[ "$is_running" -gt 0 ]]
}

# Check prerequisites
if ! command -v bc &>/dev/null; then
    echo -n "NO"
    exit 0
fi

if ! command -v docker &>/dev/null; then
    echo -n "NO"
    exit 0  
fi

if ! docker info &>/dev/null; then
    echo -n "NO"
    exit 0
fi

# Check if required files exist
if [[ ! -f "$BASE_DOCKERFILE" ]] || [[ ! -f "$OPTIMIZED_DOCKERFILE" ]]; then
    echo -n "NO"
    exit 0
fi

# Check if Rails app structure exists
if [[ ! -f "simple_app/app.py" ]] || [[ ! -f "simple_app/requirements.txt" ]]; then
    echo -n "NO"
    exit 0
fi

# Measure base build time
docker system prune -f &>/dev/null || true
docker rmi "$BASE_IMAGE" 2>/dev/null || true

start_time=$(date +%s.%N)
if ! docker build -f "$BASE_DOCKERFILE" -t "$BASE_IMAGE" . &>/dev/null; then
    echo -n "NO"
    exit 0
fi
end_time=$(date +%s.%N)
BASE_TIME=$(echo "$end_time - $start_time" | bc -l 2>/dev/null)

if [[ -z "$BASE_TIME" ]]; then
    echo -n "NO"
    exit 0
fi

# Test base functionality
if ! test_container_functionality "$BASE_IMAGE"; then
    echo -n "NO"
    exit 0
fi

# Measure optimized build time
docker system prune -f &>/dev/null || true
docker rmi "$OPTIMIZED_IMAGE" 2>/dev/null || true

start_time=$(date +%s.%N)
if ! docker build -f "$OPTIMIZED_DOCKERFILE" -t "$OPTIMIZED_IMAGE" . &>/dev/null; then
    echo -n "NO"
    exit 0
fi
end_time=$(date +%s.%N)
OPTIMIZED_TIME=$(echo "$end_time - $start_time" | bc -l 2>/dev/null)

if [[ -z "$OPTIMIZED_TIME" ]]; then
    echo -n "NO"
    exit 0
fi

# Test optimized functionality
if ! test_container_functionality "$OPTIMIZED_IMAGE"; then
    echo -n "NO"
    exit 0
fi

# Calculate improvement
IMPROVEMENT=$(echo "scale=2; (($BASE_TIME - $OPTIMIZED_TIME) / $BASE_TIME) * 100" | bc -l 2>/dev/null)
if [[ -z "$IMPROVEMENT" ]]; then
    echo -n "NO"
    exit 0
fi

# Check if improvement meets requirement
if (( $(echo "$IMPROVEMENT >= $REQUIRED_IMPROVEMENT" | bc -l 2>/dev/null) )); then
    echo -n "OK"
else
    echo -n "NO"
fi