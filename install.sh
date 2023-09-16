#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

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

arch=$(arch)

if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
    arch="amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    arch="arm64"
elif [[ $arch == "s390x" ]]; then
    arch="s390x"
else
    arch="amd64"
    echo -e "${red} Failed to check system arch, will use default arch: ${arch}${plain}"
fi

echo "arch: ${arch}"

if [ $(getconf WORD_BIT) != '32' ] && [ $(getconf LONG_BIT) != '64' ]; then
    echo "raha-xray dosen't support 32-bit(x86) system, please use 64 bit operating system(x86_64) instead, if there is something wrong, please get in touch with me!"
    exit -1
fi

os_version=""
os_version=$(grep -i version_id /etc/os-release | cut -d \" -f2 | cut -d . -f1)

if [[ "${release}" == "centos" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red} Please use CentOS 8 or higher ${plain}\n" && exit 1
    fi
elif [[ "${release}" ==  "ubuntu" ]]; then
    if [[ ${os_version} -lt 20 ]]; then
        echo -e "${red}please use Ubuntu 20 or higher version! ${plain}\n" && exit 1
    fi

elif [[ "${release}" == "fedora" ]]; then
    if [[ ${os_version} -lt 36 ]]; then
        echo -e "${red}please use Fedora 36 or higher version! ${plain}\n" && exit 1
    fi

elif [[ "${release}" == "debian" ]]; then
    if [[ ${os_version} -lt 10 ]]; then
        echo -e "${red} Please use Debian 10 or higher ${plain}\n" && exit 1
    fi
else
    echo -e "${red}Failed to check the OS version, please contact the author!${plain}" && exit 1
fi


install_base() {
    if [[ "${release}" == "centos" ]] || [[ "${release}" == "fedora" ]] ; then
        yum install wget curl tar unzip jq -y
    else
        apt install wget curl tar unzip jq -y
    fi
}

config_after_install() {
    echo -e "${yellow}List of current tokens:${plain}"
    cd /usr/local/raha-xray/
    ./rahaXray token -list
    echo -e "${yellow}Install/update finished!${plain}"
    read -p "Do you want to continue with the modification [y/n]? ": config_confirm
    if [[ "${config_confirm}" == "y" || "${config_confirm}" == "Y" ]]; then
        /usr/bin/raha-xray config 0
    fi
}

install_raha-xray() {
    cd /usr/local/

    if [ $# == 0 ]; then
        last_version=$(curl -Ls "https://api.github.com/repos/Raha-Project/raha-xray/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ ! -n "$last_version" ]]; then
            echo -e "${red}Failed to fetch raha-xray version, it maybe due to Github API restrictions, please try it later${plain}"
            exit 1
        fi
        echo -e "Got raha-xray latest version: ${last_version}, beginning the installation..."
        wget -N --no-check-certificate -O /usr/local/raha-xray-linux-${arch}.tar.gz https://github.com/Raha-Project/raha-xray/releases/download/${last_version}/raha-xray-linux-${arch}.tar.gz
        if [[ $? -ne 0 ]]; then
            echo -e "${red}Dowanloading raha-xray failed, please be sure that your server can access Github ${plain}"
            exit 1
        fi
    else
        last_version=$1
        url="https://github.com/Raha-Project/raha-xray/releases/download/${last_version}/raha-xray-linux-${arch}.tar.gz"
        echo -e "Begining to install raha-xray v$1"
        wget -N --no-check-certificate -O /usr/local/raha-xray-linux-${arch}.tar.gz ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "${red}dowanload raha-xray v$1 failed,please check the verison exists${plain}"
            exit 1
        fi
    fi

    if [[ -e /usr/local/raha-xray/ ]]; then
        systemctl stop raha-xray
    fi

    tar zxvf raha-xray-linux-${arch}.tar.gz
    rm raha-xray-linux-${arch}.tar.gz -f
    cd raha-xray
    chmod +x rahaXray
    mkdir xray-core
    wget --no-check-certificate -O /usr/bin/raha-xray https://raw.githubusercontent.com/Raha-Project/raha-xray/main/raha-xray.sh
    wget --no-check-certificate -O raha-xray.service https://raw.githubusercontent.com/Raha-Project/Raha/main/raha-xray.service
    wget --no-check-certificate -O xray.service https://raw.githubusercontent.com/Raha-Project/Raha/main/xray.service
    wget --no-check-certificate -O xray.sh https://raw.githubusercontent.com/Raha-Project/Raha/main/xray.sh


    cp -f *.service /etc/systemd/system/
    chmod +x /usr/local/raha-xray/xray.sh
    chmod +x /usr/bin/raha-xray
    config_after_install

    systemctl daemon-reload
    systemctl enable xray
    systemctl start xray
    systemctl enable raha-xray
    systemctl start raha-xray

    echo -e "${green}raha-xray v${last_version}${plain} installation finished, it is up and running now..."
    echo -e ""
    echo -e "raha-xray control menu usages: "
    echo -e "----------------------------------------------"
    echo -e "raha-xray              - Enter     Admin menu"
    echo -e "raha-xray config       - Configure raha-xray"
    echo -e "raha-xray start        - Start     raha-xray"
    echo -e "raha-xray stop         - Stop      raha-xray"
    echo -e "raha-xray restart      - Restart   raha-xray"
    echo -e "raha-xray status       - Show      raha-xray status"
    echo -e "raha-xray enable       - Enable    raha-xray on system startup"
    echo -e "raha-xray disable      - Disable   raha-xray on system startup"
    echo -e "raha-xray log          - Check     raha-xray logs"
    echo -e "raha-xray update       - Update    raha-xray"
    echo -e "raha-xray install      - Install   raha-xray"
    echo -e "raha-xray uninstall    - Uninstall raha-xray"
    echo -e "----------------------------------------------"
}

echo -e "${green}Excuting...${plain}"
install_base
install_raha-xray $1
