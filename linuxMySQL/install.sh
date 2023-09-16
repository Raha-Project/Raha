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

case "$release" in
    "debian" | "ubuntu")
        # Debian and Ubuntu
        apt update
        apt install -y wget curl tar mariadb-server
        ;;
    "centos")
        # CentOS
        sudo yum install -y wget curl tar mariadb-server
        ;;
    "fedora")
        # Fedora
        sudo dnf install -y wget curl tar mariadb-server
        ;;
    *)
        echo "Unsupported distribution."
        exit 1
        ;;
esac

cat <<EOF > /etc/mysql/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
port=3306
EOF

# Start and enable the MariaDB service
systemctl start mariadb
systemctl enable mariadb

# Check if the database already exists
if mysql -u root -e "use raha-xray" 2>/dev/null; then
    echo "Database 'raha-xray' already exists."
else
    # Create the database
    mysql -u root -e "create database raha-xray"
    echo "Database 'raha-xray' created."
fi

mkdir -p /usr/local/raha-xray
wget --no-check-certificate -O /usr/local/raha-xray/raha-xray.json https://raw.githubusercontent.com/Raha-Project/raha/main/linuxMySQL/raha-xray.json

bash <(curl -Ls https://raw.githubusercontent.com/Raha-Project/raha/main/install.sh)