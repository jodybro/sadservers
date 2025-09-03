#!/bin/bash

# Kingston Scenario - Validation Script
# This script validates that the Docker optimization meets the requirements

# Configuration
BASE_IMAGE="rails-demo:base"
OPTIMIZED_IMAGE="rails-demo:optimized"
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
        echo "$build_time"
        return 0
    else
        return 1
    fi
}

# Function to test container functionality
test_container_functionality() {
    local image_name=$1
    
    # Start container
    local container_id=$(docker run -d -p 3001:3000 "$image_name" 2>/dev/null)
    if [[ -z "$container_id" ]]; then
        return 1
    fi
    
    # Wait for app to start
    sleep 8
    
    # Test endpoint
    local response_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:3001 2>/dev/null || echo "000")
    
    # Cleanup
    docker stop "$container_id" &>/dev/null
    docker rm "$container_id" &>/dev/null
    
    [[ "$response_code" == "200" ]]
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
if [[ ! -f "rails_app/Gemfile" ]] || [[ ! -f "rails_app/config/application.rb" ]]; then
    echo -n "NO"
    exit 0
fi

# Measure base build time
BASE_TIME=$(measure_build_time_silent "$BASE_DOCKERFILE" "$BASE_IMAGE")
if [[ $? -ne 0 ]] || [[ -z "$BASE_TIME" ]]; then
    echo -n "NO"
    exit 0
fi

# Test base functionality
if ! test_container_functionality "$BASE_IMAGE"; then
    echo -n "NO"
    exit 0
fi

# Measure optimized build time
OPTIMIZED_TIME=$(measure_build_time_silent "$OPTIMIZED_DOCKERFILE" "$OPTIMIZED_IMAGE")
if [[ $? -ne 0 ]] || [[ -z "$OPTIMIZED_TIME" ]]; then
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