#!/bin/bash

# Kingston Scenario Setup Script
# This script prepares the environment for Docker build optimization testing

set -e

echo "🚢 Kingston Docker Build Optimization Scenario Setup"
echo "=================================================="

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    echo "Please install Docker to run this scenario"
    exit 1
fi

echo "✅ Docker is available"

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running"
    echo "Please start Docker daemon to continue"
    exit 1
fi

echo "✅ Docker daemon is running"

# Clean up any existing images from previous runs
echo "🧹 Cleaning up any existing images..."
docker rmi rails-demo:base 2>/dev/null || true
docker rmi rails-demo:optimized 2>/dev/null || true
docker system prune -f &>/dev/null || true

echo "✅ Cleanup completed"

# Verify all required files are present
REQUIRED_FILES=(
    "Dockerfile.base"
    "Dockerfile.optimized" 
    "rails_app/Gemfile"
    "rails_app/config/application.rb"
    "rails_app/config/routes.rb"
    "rails_app/app/controllers/home_controller.rb"
    "time_builds.sh"
    "check.sh"
)

echo "📋 Verifying required files..."
for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "❌ Missing required file: $file"
        exit 1
    fi
done

echo "✅ All required files are present"

# Make scripts executable
chmod +x time_builds.sh check.sh
if [[ -f "rails_app/bin/rails" ]]; then
    chmod +x rails_app/bin/rails
fi

echo "✅ Scripts made executable"

# Create any missing directories in Rails app
mkdir -p rails_app/tmp/cache
mkdir -p rails_app/tmp/pids  
mkdir -p rails_app/log
mkdir -p rails_app/public/assets

echo "✅ Rails app directory structure verified"

# Test Docker build context
echo "🔍 Testing Docker build context..."
docker build -f Dockerfile.base -t test-context --dry-run . &>/dev/null || {
    echo "❌ Docker build context test failed"
    echo "Please check Dockerfile.base and .dockerignore"
    exit 1
}

echo "✅ Docker build context is valid"

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Run ./time_builds.sh to measure build times"
echo "2. Optimize Dockerfile.optimized if needed" 
echo "3. Run ./check.sh to validate your solution"
echo ""