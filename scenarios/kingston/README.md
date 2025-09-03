# Kingston: Docker Build Optimization

## Description

You are tasked with optimizing the Docker build process for a Python application. The current Dockerfile has several inefficiencies including unnecessary layers, poor caching, large base images, and suboptimal commands that result in slow build times.

Your goal is to optimize the Dockerfile to achieve at least a 10% improvement in build time while maintaining the same functionality. The scenario includes both a base (inefficient) Dockerfile and your task is to create an optimized version that demonstrates best practices such as:

- Multi-stage builds
- Improved layer caching
- Better dependency management
- Optimized base image selection
- Reduced image size

## Test

Run the provided scripts to measure and compare build times:

1. First, run `setup_scenario.sh` to prepare the environment
2. Then run `time_builds.sh` to measure build times of both Dockerfiles
3. The optimized build must be at least 10% faster than the base build

The "Check My Solution" button runs the script `/home/admin/agent/check.sh`, which you can see and execute.

**check.sh**

The check script will:
1. Verify both Dockerfiles can build successfully
2. Measure build times for both versions
3. Confirm the optimized version is at least 10% faster
4. Ensure the resulting applications function identically

## Files Provided

- `simple_app/` - A sample Python application for testing
- `Dockerfile.base` - The inefficient starting Dockerfile
- `Dockerfile.optimized` - Template for your optimized version
- `setup_scenario.sh` - Environment setup script
- `time_builds.sh` - Build timing comparison script
- `check.sh` - Validation script

## Hints

1. Consider using multi-stage builds to separate build dependencies from runtime
2. Order your COPY and RUN commands to maximize Docker layer caching
3. Use more specific base images (e.g., ruby:3.1-alpine vs ubuntu:latest)
4. Bundle dependencies separately from application code
5. Consider using .dockerignore to reduce build context size