#!/bin/bash

# Kingston Scenario - Docker Build Time Comparison Script
# Measures and compares build times between base and optimized Dockerfiles

set -e

echo "⏱️  Kingston Docker Build Time Comparison"
echo "========================================"

# Configuration
BASE_IMAGE="rails-demo:base"
OPTIMIZED_IMAGE="rails-demo:optimized" 
BASE_DOCKERFILE="Dockerfile.base"
OPTIMIZED_DOCKERFILE="Dockerfile.optimized"

# Function to measure build time
measure_build_time() {
    local dockerfile=$1
    local image_name=$2
    local build_type=$3
    
    echo "🔨 Building $build_type version..."
    echo "   Dockerfile: $dockerfile"
    echo "   Image name: $image_name"
    
    # Clean build - no cache
    docker system prune -f &>/dev/null || true
    
    # Measure build time
    local start_time=$(date +%s.%N)
    
    if docker build -f "$dockerfile" -t "$image_name" . &>/dev/null; then
        local end_time=$(date +%s.%N)
        local build_time=$(echo "$end_time - $start_time" | bc -l)
        echo "✅ $build_type build completed in ${build_time} seconds"
        echo "$build_time"
    else
        echo "❌ $build_type build failed!"
        return 1
    fi
}

# Function to test functionality
test_functionality() {
    local image_name=$1
    local build_type=$2
    
    echo "🧪 Testing $build_type functionality..."
    
    # Start container
    local container_id=$(docker run -d -p 3000:3000 "$image_name")
    
    # Wait for app to start
    sleep 10
    
    # Test endpoint
    local response_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || echo "000")
    
    # Stop container
    docker stop "$container_id" &>/dev/null
    docker rm "$container_id" &>/dev/null
    
    if [[ "$response_code" == "200" ]]; then
        echo "✅ $build_type version is functional"
        return 0
    else
        echo "❌ $build_type version failed (HTTP $response_code)"
        return 1
    fi
}

# Function to calculate improvement percentage
calculate_improvement() {
    local base_time=$1
    local optimized_time=$2
    
    local improvement=$(echo "scale=2; (($base_time - $optimized_time) / $base_time) * 100" | bc -l)
    echo "$improvement"
}

# Check prerequisites
if ! command -v bc &> /dev/null; then
    echo "❌ bc (basic calculator) is required but not installed"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not available"
    exit 1
fi

if [[ ! -f "$BASE_DOCKERFILE" ]]; then
    echo "❌ Base Dockerfile not found: $BASE_DOCKERFILE"
    exit 1
fi

if [[ ! -f "$OPTIMIZED_DOCKERFILE" ]]; then
    echo "❌ Optimized Dockerfile not found: $OPTIMIZED_DOCKERFILE"
    exit 1
fi

# Clean up any existing images
echo "🧹 Cleaning up existing images..."
docker rmi "$BASE_IMAGE" 2>/dev/null || true
docker rmi "$OPTIMIZED_IMAGE" 2>/dev/null || true

echo ""

# Measure base build time
echo "📊 Measuring base build time..."
BASE_TIME=$(measure_build_time "$BASE_DOCKERFILE" "$BASE_IMAGE" "base")
if [[ $? -ne 0 ]]; then
    exit 1
fi

echo ""

# Test base functionality
test_functionality "$BASE_IMAGE" "base"
if [[ $? -ne 0 ]]; then
    echo "❌ Base image is not functional, cannot proceed"
    exit 1
fi

echo ""

# Measure optimized build time
echo "📊 Measuring optimized build time..."
OPTIMIZED_TIME=$(measure_build_time "$OPTIMIZED_DOCKERFILE" "$OPTIMIZED_IMAGE" "optimized")
if [[ $? -ne 0 ]]; then
    exit 1
fi

echo ""

# Test optimized functionality
test_functionality "$OPTIMIZED_IMAGE" "optimized"
if [[ $? -ne 0 ]]; then
    echo "❌ Optimized image is not functional!"
    exit 1
fi

echo ""

# Calculate and display results
echo "📈 Build Time Comparison Results"
echo "================================"
echo "Base build time:      ${BASE_TIME} seconds"
echo "Optimized build time: ${OPTIMIZED_TIME} seconds"

IMPROVEMENT=$(calculate_improvement "$BASE_TIME" "$OPTIMIZED_TIME")
echo "Time improvement:     ${IMPROVEMENT}%"

echo ""

# Check if improvement meets requirement
REQUIRED_IMPROVEMENT=10.0
if (( $(echo "$IMPROVEMENT >= $REQUIRED_IMPROVEMENT" | bc -l) )); then
    echo "🎉 SUCCESS! Optimization achieved ${IMPROVEMENT}% improvement (≥${REQUIRED_IMPROVEMENT}% required)"
    echo ""
    echo "Additional metrics:"
    
    # Image size comparison
    BASE_SIZE=$(docker images "$BASE_IMAGE" --format "{{.Size}}")
    OPTIMIZED_SIZE=$(docker images "$OPTIMIZED_IMAGE" --format "{{.Size}}")
    echo "Base image size:      $BASE_SIZE"
    echo "Optimized image size: $OPTIMIZED_SIZE"
    
    # Layer count
    BASE_LAYERS=$(docker history "$BASE_IMAGE" --quiet | wc -l)
    OPTIMIZED_LAYERS=$(docker history "$OPTIMIZED_IMAGE" --quiet | wc -l)
    echo "Base image layers:    $BASE_LAYERS"
    echo "Optimized layers:     $OPTIMIZED_LAYERS"
    
    exit 0
else
    echo "❌ FAILED! Only ${IMPROVEMENT}% improvement achieved (${REQUIRED_IMPROVEMENT}% required)"
    echo ""
    echo "Suggestions for further optimization:"
    echo "- Use multi-stage builds to separate build and runtime dependencies"
    echo "- Optimize layer caching by copying Gemfile first"
    echo "- Use a smaller base image (e.g., Alpine Linux)"
    echo "- Combine RUN commands to reduce layers"
    echo "- Use .dockerignore to reduce build context"
    exit 1
fi