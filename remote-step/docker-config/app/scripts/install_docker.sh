#!/bin/env sh

docker -v
if [ $? -eq 0 ]; then
    echo "Docker is already installed"
    exit 0
fi

function debain_install_docker() {
    # Add Docker's official GPG key:
    apt-get update
    apt-get install ca-certificates curl gnupg -y
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update

    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

function ubuntu_install_docker() {
    # Add Docker's official GPG key:
    apt-get update
    apt-get install ca-certificates curl gnupg -y
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update

    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

function centos_install_docker() {
    yum install yum-utils -y
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    systemctl start docker
}

# Must be root user
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Check OS and install docker
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [[ $OS == *"Debian"* ]]; then
    debain_install_docker
elif [[ $OS == *"Ubuntu"* ]]; then
    ubuntu_install_docker
elif [[ $OS == *"CentOS"* ]]; then
    centos_install_docker
fi