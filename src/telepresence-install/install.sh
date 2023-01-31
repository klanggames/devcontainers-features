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

if [ $(uname -m) = 'x86_64' ]; then echo -n "x86_64" >/tmp/arch; else echo -n "arm64" >/tmp/arch; fi
ARCH=$(cat /tmp/arch)

curl -fL "https://app.getambassador.io/download/tel2/linux/${ARCH}/${VERSION}/telepresence" -o /usr/local/bin/telepresence
chmod a+x /usr/local/bin/telepresence
