#!/bin/bash

set -e

defaultXrayVersion="v1.8.4"

if [[ arch == "arm64" ]]; then
    ARCH="arm64-v8a"
else
    ARCH="64"
fi

os=$(uname | tr '[:upper:]' '[:lower:]')
if [ $os == "darwin" ]; then
    os="macos"
fi

if [ ! -d xray-core ]; then
    mkdir -p xray-core  
fi
cd xray-core

# Default version
if [[ ! -f version ]]; then
    echo "$defaultXrayVersion" > version
    VERSION="$defaultXrayVersion"
else
    VERSION=`cat version`
fi

# Get xray version
if [[ -f "xray-$os" ]]; then
    XrayVersion=`"./xray-$os" -version | head -n 1 | awk -F " " '{print $2}'`
fi

if [[ "$VERSION" != "v$XrayVersion" ]]; then
    rm -fr download
    mkdir download
    cd download
    wget "https://github.com/XTLS/Xray-core/releases/download/$VERSION/Xray-$os-$ARCH.zip" -q -O xray.zip
    unzip "xray.zip"
    cd ..
    rm -f xray-* *.dat
    mv download/xray "xray-${os}"
    rm -fr download
    chmod +x "xray-${os}"
    wget "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat" -q
    wget "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat" -q
    wget "https://github.com/Masterkia/iran-hosted-domains/releases/latest/download/iran.dat" -q
fi
cd ..
tokill=$$

terminatexray()
{
    echo "Killing the xray-core PID=$tokill"
    kill $tokill
    while kill -0 $tokill > /dev/null 2>&1; do
        sleep 1
    done
}

trap terminatexray SIGINT SIGTERM SIGKILL

xray-core/xray-$os &
tokill=$!
while true
do
    sleep 5
    if [ -f "xray-core/xraysignal" ]; then
        signal=`cat xray-core/xraysignal`
        echo "Signal received: $signal"
        # Remove singnal file
        rm -f xray-core/xraysignal >> /dev/null 2>&1
        case ${signal} in 
            "stop")
                terminatexray
                ;;
            "restart")
                terminatexray
                exit
                ;;
        esac
    fi
    if ! kill -0 $tokill > /dev/null 2>&1; then
        exit
    fi
done