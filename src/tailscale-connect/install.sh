#!/bin/bash
set -e

echo "Establish connection to tailscale"
sudo tailscale up --authkey=$AUTHKEY --accept-routes --accept-dns=false

if [ $? -eq 0 ]; then
    echo "Connection established"
else
    echo "Connection failed"
fi
