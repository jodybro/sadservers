#!/bin/bash

# Check script for Docker Image Build Optimization scenario
# Validates that the optimized Docker build achieves >= 10% improvement over base build

# Default admin home directory (can be overridden)
ADMIN_HOME="${ADMIN_HOME:-/home/admin}"
SCENARIO_DIR="$ADMIN_HOME/docker-optimization"
IMPROVEMENT_FILE="$SCENARIO_DIR/improvement.txt"
BASE_TIME_FILE="$SCENARIO_DIR/base_time.txt"
OPTIMIZED_TIME_FILE="$SCENARIO_DIR/optimized_time.txt"

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "NO"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "NO"
    exit 1
fi

# Check if the scenario directory exists
if [ ! -d "$SCENARIO_DIR" ]; then
    echo "NO"
    exit 1
fi

# Check if Dockerfiles exist
if [ ! -f "$SCENARIO_DIR/Dockerfile.base" ] || [ ! -f "$SCENARIO_DIR/Dockerfile.optimized" ]; then
    echo "NO"
    exit 1
fi

# Check if build timing has been run
if [ ! -f "$IMPROVEMENT_FILE" ] || [ ! -f "$BASE_TIME_FILE" ] || [ ! -f "$OPTIMIZED_TIME_FILE" ]; then
    echo "NO"
    exit 1
fi

# Read the improvement percentage
if [ -f "$IMPROVEMENT_FILE" ]; then
    improvement=$(cat "$IMPROVEMENT_FILE")
    
    # Extract integer part of improvement (before decimal point)
    improvement_int=$(echo "$improvement" | cut -d'.' -f1)
    
    # Check if improvement is >= 10%
    if [ "$improvement_int" -ge 10 ]; then
        echo "OK"
        exit 0
    else
        echo "NO"
        exit 1
    fi
else
    echo "NO"
    exit 1
fi
