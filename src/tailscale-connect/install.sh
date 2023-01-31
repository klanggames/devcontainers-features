#!/bin/bash
set -e

echo "Establish connection to tailscale"
tailscale up --authkey=$AUTHKEY --accept-routes --accept-dns=false

if [ $? -eq 0 ]; then
    echo "Connection established"
else
    echo "Connection failed"
fi
