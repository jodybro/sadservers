#!/bin/bash

# Setup script for Docker optimization scenario
# Creates the scenario environment and copies necessary files

SCENARIO_DIR="/home/admin/docker-optimization"

echo "Setting up Docker Image Build Optimization scenario..."

# Create scenario directory
mkdir -p "$SCENARIO_DIR/app"

# Copy Dockerfiles
cp /home/admin/Dockerfile.base "$SCENARIO_DIR/"
cp /home/admin/Dockerfile.optimized "$SCENARIO_DIR/"

# Create basic Rails app structure for Docker builds
mkdir -p "$SCENARIO_DIR/app/tmp/pids"
mkdir -p "$SCENARIO_DIR/app/config"
mkdir -p "$SCENARIO_DIR/app/app/assets"

# Copy application files
cp /home/admin/Gemfile "$SCENARIO_DIR/app/"
cp /home/admin/Gemfile.lock "$SCENARIO_DIR/app/"
cp /home/admin/entrypoint.sh "$SCENARIO_DIR/app/"
cp /home/admin/sidekiq_shutdown.rb "$SCENARIO_DIR/app/"

# Create minimal Rails configuration files
cat > "$SCENARIO_DIR/app/config/application.rb" << 'EOF'
require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module DockerOptimizationApp
  class Application < Rails::Application
    config.load_defaults 6.1
  end
end
EOF

cat > "$SCENARIO_DIR/app/config/boot.rb" << 'EOF'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
require "bundler/setup"
require "bootsnap/setup"
EOF

# Create Rakefile
cat > "$SCENARIO_DIR/app/Rakefile" << 'EOF'
require_relative "config/application"
Rails.application.load_tasks
EOF

# Create simple asset files for precompilation
mkdir -p "$SCENARIO_DIR/app/app/assets/stylesheets"
echo "/* Application styles */" > "$SCENARIO_DIR/app/app/assets/stylesheets/application.css"

mkdir -p "$SCENARIO_DIR/app/app/assets/javascripts"
echo "// Application JavaScript" > "$SCENARIO_DIR/app/app/assets/javascripts/application.js"

# Set permissions
chmod +x "$SCENARIO_DIR/app/entrypoint.sh"
chmod +x "$SCENARIO_DIR/app/sidekiq_shutdown.rb"

echo "Scenario setup complete!"
echo ""
echo "To run the optimization test:"
echo "1. cd $SCENARIO_DIR"
echo "2. Run: ./time_builds.sh"
echo ""
echo "The goal is to optimize the Dockerfile.optimized to achieve >10% build time improvement over Dockerfile.base"