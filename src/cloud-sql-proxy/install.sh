#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

latest=2.3.0
VERSION=${VERSION:-undefined}

# if no version is specified, use the latest
if [ "$VERSION" = "undefined" ]; then
    CLOUD_SQL_PROXY_VERSION=$latest
else
    CLOUD_SQL_PROXY_VERSION=$VERSION
fi

curl -o /usr/local/bin/cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v${CLOUD_SQL_PROXY_VERSION}/cloud-sql-proxy.linux.amd64

chmod +x /usr/local/bin/cloud-sql-proxy