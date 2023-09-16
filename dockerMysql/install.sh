#!/bin/bash

# check root
[[ $EUID -ne 0 ]] && LOGE "ERROR: You must be root to run this script! \n" && exit 1

# Check OS and set release variable
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    release=$ID
elif [[ -f /usr/lib/os-release ]]; then
    source /usr/lib/os-release
    release=$ID
else
    echo "Failed to check the system OS, please contact the author!" >&2
    exit 1
fi
echo "The OS release is: $release"

# Function to install Docker on Debian/Ubuntu
install_docker_debian() {
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
}

# Function to install Docker on CentOS
install_docker_centos() {
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
}

# Function to install Docker Compose
install_docker_compose() {
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

case "$release" in
    "debian" | "ubuntu")
        # Debian and Ubuntu
        install_docker_debian
        apt install -y wget curl tar
        ;;
    "centos")
        # CentOS
        install_docker_centos
        sudo yum install -y wget curl tar
        ;;
    "fedora")
        # Fedora
        sudo dnf install -y wget curl tar docker
        ;;
    *)
        echo "Unsupported distribution."
        exit 1
        ;;
esac

install_docker_compose

wget --no-check-certificate -O xray.sh https://raw.githubusercontent.com/Raha-Project/Raha/main/dockerMysql/xray.sh
wget --no-check-certificate -O rsyslog.conf https://raw.githubusercontent.com/Raha-Project/Raha/main/dockerMysql/rsyslog.conf
wget --no-check-certificate -O raha-xray.json https://raw.githubusercontent.com/Raha-Project/Raha/main/dockerMysql/raha-xray.json
wget --no-check-certificate -O docker-compose.yaml https://raw.githubusercontent.com/Raha-Project/Raha/main/dockerMysql/docker-compose.yaml

mkdir cert
mkdir db

docker-compose up -d