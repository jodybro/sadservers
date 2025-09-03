# "Kingston": Docker Image Build Optimization

## Introduction

Welcome to the Kingston scenario! This challenge focuses on optimizing Docker image build times for a Ruby on Rails application. You'll be working with a real-world Dockerfile that has several optimization opportunities.

## Scenario Description

You have been given a Ruby on Rails application with a poorly optimized Dockerfile that takes a long time to build. Your task is to optimize the Docker build process to achieve **at least a 10% reduction in build time** compared to the base implementation.

## The Challenge

The scenario includes:
- **Dockerfile.base**: An unoptimized Dockerfile with multiple inefficiencies
- **Dockerfile.optimized**: A pre-optimized version that you can study and improve further
- **Sample Rails app**: A minimal Rails application for testing builds
- **Timing script**: Automated build time comparison tool

## Common Docker Optimization Techniques

Here are some optimization strategies you might consider:

### 1. **Layer Caching Optimization**
- Order instructions from least to most frequently changing
- Copy dependency files before application code
- Use `.dockerignore` to exclude unnecessary files

### 2. **Reduce Layer Count**
- Combine multiple RUN statements
- Chain commands with `&&`
- Clean up in the same layer where packages are installed

### 3. **Multi-stage Builds**
- Separate build dependencies from runtime dependencies
- Use a smaller base image for the final stage
- Copy only necessary artifacts between stages

### 4. **Base Image Selection**
- Use more recent, optimized base images
- Consider Alpine Linux for smaller images
- Use official language-specific images when appropriate

### 5. **Package Management**
- Use `--no-install-recommends` for apt packages
- Clean package caches in the same layer
- Pin package versions for reproducible builds

### 6. **Build Context Optimization**
- Minimize build context size
- Use `.dockerignore` effectively
- Avoid sending unnecessary files to Docker daemon

## Getting Started

1. **Explore the current setup:**
   ```bash
   cd /home/admin/docker-optimization
   ls -la
   ```

2. **Examine the base Dockerfile:**
   ```bash
   cat Dockerfile.base
   ```

3. **Study the optimized version:**
   ```bash
   cat Dockerfile.optimized
   ```

4. **Run the build time comparison:**
   ```bash
   ./time_builds.sh
   ```

## Success Criteria

The scenario is considered complete when:
- Both Dockerfiles build successfully
- The optimized build is **at least 10% faster** than the base build
- The optimization maintains the same functionality

## Tips for Success

- **Start with the obvious wins**: Look for repeated `RUN` commands, unnecessary downloads, and poor layer ordering
- **Use Docker's build cache effectively**: Structure your Dockerfile to maximize cache hits
- **Monitor build progress**: Use `docker build --progress=plain` to see detailed build steps
- **Test iteratively**: Make small changes and test frequently
- **Consider the application needs**: Don't break functionality while optimizing

## Validation

Run the check script to validate your solution:
```bash
/home/admin/agent/check.sh
```

This will verify that your optimization achieves the required 10% improvement in build time.

## Files in this Scenario

- `Dockerfile.base` - The unoptimized Dockerfile (starting point)
- `Dockerfile.optimized` - An optimized version to study and improve
- `time_builds.sh` - Script to measure and compare build times
- `setup_scenario.sh` - Initial scenario setup script
- `Gemfile`, `Gemfile.lock` - Rails application dependencies
- `entrypoint.sh` - Docker container entrypoint script
- Sample Rails application files for realistic build testing

Good luck with your Docker optimization challenge!