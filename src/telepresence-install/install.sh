#!/bin/bash
set -e

# replace "." in domain with "-"
DOMAIN_DASHED=$(echo "$DOMAIN" | sed 's/\./-/g')

# install dependencies
echo "Installing dependencies..."
apt update && apt install -y --no-install-recommends \
    curl

# install telepresence
echo "Installing telepresence..."

if [ $(uname -m) = 'x86_64' ]; then echo -n "amd64" >/tmp/arch; else echo -n "arm64" >/tmp/arch; fi
ARCH=$(cat /tmp/arch)

URL="https://app.getambassador.io/download/tel2/linux/${ARCH}/${VERSION}/telepresence"
echo "Downloading ${URL}..."
curl -fL "${URL}" -o /usr/local/bin/telepresence
chmod a+x /usr/local/bin/telepresence
