# Debian AMI for Kingston Docker Optimization Scenario

packer {
  required_plugins {
    amazon = {
      version = "= 1.2.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "debian" {
  ami_name                    = "scenario-kingston-docker-optimization"
  instance_type               = "t3a.small"
  region                      = "${var.region}"
  vpc_id                      = "${var.vpc_id}"
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = true
  source_ami                  = "${var.source_ami}"
  ssh_username                = "admin"
}

build {
  name = "debian-build"
  sources = [
    "source.amazon-ebs.debian"
  ]

  # OS & Docker setup
  provisioner "shell" {
    inline = [
      "echo Installing Docker prerequisites...",
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release bc",
    ]
  }

  # Install Docker
  provisioner "shell" {
    inline = [
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "sudo usermod -aG docker admin",
    ]
  }

  # Copy Docker scenario files
  provisioner "file" {
    source      = "../files/Dockerfile.base"
    destination = "/tmp/Dockerfile.base"
  }

  provisioner "file" {
    source      = "../files/Dockerfile.optimized"  
    destination = "/tmp/Dockerfile.optimized"
  }

  provisioner "file" {
    source      = "../files/time_builds.sh"
    destination = "/tmp/time_builds.sh"
  }

  provisioner "file" {
    source      = "../files/setup_scenario.sh"
    destination = "/tmp/setup_scenario.sh"
  }

  provisioner "file" {
    source      = "../files/Gemfile"
    destination = "/tmp/Gemfile"
  }

  provisioner "file" {
    source      = "../files/Gemfile.lock"
    destination = "/tmp/Gemfile.lock"
  }

  provisioner "file" {
    source      = "../files/entrypoint.sh"
    destination = "/tmp/entrypoint.sh"
  }

  provisioner "file" {
    source      = "../files/sidekiq_shutdown.rb"
    destination = "/tmp/sidekiq_shutdown.rb"
  }

  # Setup scenario files
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /home/admin/agent",
      "sudo mv /tmp/Dockerfile.base /home/admin/",
      "sudo mv /tmp/Dockerfile.optimized /home/admin/", 
      "sudo mv /tmp/time_builds.sh /home/admin/",
      "sudo mv /tmp/setup_scenario.sh /home/admin/",
      "sudo mv /tmp/Gemfile /home/admin/",
      "sudo mv /tmp/Gemfile.lock /home/admin/",
      "sudo mv /tmp/entrypoint.sh /home/admin/",
      "sudo mv /tmp/sidekiq_shutdown.rb /home/admin/",
      "sudo chmod +x /home/admin/time_builds.sh",
      "sudo chmod +x /home/admin/setup_scenario.sh",
      "sudo chmod +x /home/admin/entrypoint.sh",
      "sudo chmod +x /home/admin/sidekiq_shutdown.rb",
      "sudo chown -R admin:admin /home/admin/",
    ]
  }

  # Setup Docker optimization scenario
  provisioner "shell" {
    inline = [
      "sudo -u admin /home/admin/setup_scenario.sh",
    ]
  }

  # check.sh
  provisioner "file" {
    source      = "../files/check.sh"
    destination = "/tmp/check.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/check.sh /home/admin/agent/check.sh",
      "sudo chmod +x /home/admin/agent/check.sh",
    ]
  }

}
