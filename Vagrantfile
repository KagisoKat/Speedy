Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "speedy-dev"

  # Give the VM enough resources for containers
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4096
    vb.cpus = 2
  end

  # Private network IP (optional but useful)
  config.vm.network "private_network", ip: "192.168.56.20"

  # Forward ports from VM -> Windows (so you can browse on host)
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true   # NGINX
  config.vm.network "forwarded_port", guest: 5000, host: 5000, auto_correct: true # API
  config.vm.network "forwarded_port", guest: 5173, host: 5173, auto_correct: true # React dev
  config.vm.network "forwarded_port", guest: 5432, host: 5433, auto_correct: true # Postgres (host 5433 to avoid clashes)

  # Sync your repo into the VM (default: /vagrant)
  # If you hit slowness on Windows, we can switch to rsync later.
  config.vm.synced_folder ".", "/vagrant"

  # Provision: install Docker Engine + Compose plugin
  config.vm.provision "shell", inline: <<-SHELL
    set -e

    # Basic packages
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release

    # Docker official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Docker repo
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list

    apt-get update -y

    # Install Docker Engine + compose plugin
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Enable docker
    systemctl enable docker
    systemctl start docker

    # Allow 'vagrant' user to run docker without sudo
    usermod -aG docker vagrant

    echo "Docker version:"
    docker --version || true
    echo "Docker Compose version:"
    docker compose version || true
  SHELL
end
