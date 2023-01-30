#!/bin/bash
set -e

set -x
# setup cli mode for debian

# setup headless ode debian
export DEBIAN_FRONTEND=noninteractive

latest=415.0.0
VERSION=${VERSION:-undefined}

if [ $(uname -m) = 'x86_64' ]; then echo -n "x86_64" >/tmp/arch; else echo -n "arm" >/tmp/arch; fi
ARCH=$(cat /tmp/arch)

# if no version is specified, use the latest
if [ "$VERSION" = "undefined" ]; then
    CLOUD_SDK_VERSION=$latest
else
    CLOUD_SDK_VERSION=$VERSION
fi

# install dependencies
apt update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    python3 \
    python3-distutils \
    python3-apt \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    software-properties-common \
    unzip
#echo $?
curl -fsSL "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-${ARCH}.tar.gz" | tar -C /usr/local -xzf -
/usr/local/google-cloud-sdk/install.sh -q --usage-reporting=false --rc-path=/etc/bash.bashrc --path-update=true --bash-completion=true
