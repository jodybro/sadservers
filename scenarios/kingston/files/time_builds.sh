#!/bin/bash

# Docker Image Build Time Comparison Script
# This script builds both the base and optimized Dockerfiles and compares build times

# Default admin home directory (can be overridden)
ADMIN_HOME="${ADMIN_HOME:-/home/admin}"
SCENARIO_DIR="$ADMIN_HOME/docker-optimization"
BASE_DOCKERFILE="$SCENARIO_DIR/Dockerfile.base"
OPTIMIZED_DOCKERFILE="$SCENARIO_DIR/Dockerfile.optimized"
APP_DIR="$SCENARIO_DIR/app"

# Results file
RESULTS_FILE="$SCENARIO_DIR/build_times.txt"

echo "Docker Image Build Time Comparison" > "$RESULTS_FILE"
echo "====================================" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# Function to build and time a Docker image
build_and_time() {
    local dockerfile=$1
    local image_name=$2
    local label=$3
    
    echo "Building $label..."
    echo "Building $label..." >> "$RESULTS_FILE"
    
    # Clear Docker cache to ensure fair comparison
    docker builder prune -f >/dev/null 2>&1
    
    # Time the build
    start_time=$(date +%s)
    
    # Build the image (show build output)
    if docker build -f "$dockerfile" -t "$image_name" "$APP_DIR"; then
        end_time=$(date +%s)
        build_time=$((end_time - start_time))
        echo "Build time: ${build_time} seconds"
        echo "Build time: ${build_time} seconds" >> "$RESULTS_FILE"
        echo "$build_time"
    else
        echo "Build failed!" 
        echo "Build failed!" >> "$RESULTS_FILE"
        echo "-1"
    fi
    
    echo "" >> "$RESULTS_FILE"
}

# Ensure we're in the right directory
cd "$SCENARIO_DIR" || exit 1

# Build base image
echo "=== Building Base Docker Image ==="
base_time=$(build_and_time "$BASE_DOCKERFILE" "rails-app:base" "Base Image")

if [ "$base_time" -eq -1 ]; then
    echo "Base image build failed. Cannot proceed with comparison."
    exit 1
fi

# Build optimized image  
echo "=== Building Optimized Docker Image ==="
optimized_time=$(build_and_time "$OPTIMIZED_DOCKERFILE" "rails-app:optimized" "Optimized Image")

if [ "$optimized_time" -eq -1 ]; then
    echo "Optimized image build failed. Cannot proceed with comparison."
    exit 1
fi

# Calculate improvement using shell arithmetic (fallback if bc not available)
echo "=== Results ===" >> "$RESULTS_FILE"
echo "Base build time: ${base_time} seconds" >> "$RESULTS_FILE"
echo "Optimized build time: ${optimized_time} seconds" >> "$RESULTS_FILE"

if [ "$base_time" -gt 0 ]; then
    # Calculate improvement percentage using shell arithmetic
    # improvement = ((base_time - optimized_time) * 100) / base_time
    time_saved=$((base_time - optimized_time))
    improvement_x100=$(((base_time - optimized_time) * 10000 / base_time))
    improvement=$((improvement_x100 / 100))
    improvement_decimal=$((improvement_x100 % 100))
    
    echo "Time saved: ${time_saved} seconds" >> "$RESULTS_FILE"
    echo "Improvement: ${improvement}.${improvement_decimal}%" >> "$RESULTS_FILE"
    
    echo ""
    echo "=== Build Time Comparison Results ==="
    echo "Base build time: ${base_time} seconds"
    echo "Optimized build time: ${optimized_time} seconds" 
    echo "Time saved: ${time_saved} seconds"
    echo "Improvement: ${improvement}.${improvement_decimal}%"
    
    # Store times for check script
    echo "$base_time" > "$SCENARIO_DIR/base_time.txt"
    echo "$optimized_time" > "$SCENARIO_DIR/optimized_time.txt"
    echo "${improvement}.${improvement_decimal}" > "$SCENARIO_DIR/improvement.txt"
    
    # Check if improvement is >= 10% (using integer comparison)
    if [ "$improvement" -ge 10 ]; then
        echo ""
        echo "🎉 SUCCESS: Optimization achieved ${improvement}.${improvement_decimal}% improvement (>= 10% required)"
        exit 0
    else
        echo ""
        echo "❌ INSUFFICIENT: Optimization achieved only ${improvement}.${improvement_decimal}% improvement (>= 10% required)"
        exit 1
    fi
else
    echo "Error: Invalid build time"
    exit 1
fi