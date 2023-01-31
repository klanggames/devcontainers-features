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

# auth gcloud first, requires some user input
echo "Authenticating gcloud..."
echo "You will be asked to authenticate with your Google account twice."
# set project
gcloud config set project $PROJECT
# login if not already logged in (test if 'gcloud config get account' returns an email address)
if ! gcloud config get account | grep -q "@"; then
    gcloud auth login
fi
# set application default credentials if not already set (test if 'gcloud auth application-default print-access-token' returns a token)
if ! gcloud auth application-default print-access-token | grep -q "ya29"; then
    gcloud auth application-default login
fi

echo "Finding the zone of the cluster..."
ZONE=$(gcloud container clusters list --format json --project $PROJECT | jq -r ".[] | select(.name == \"$DOMAIN_DASHED\") | .zone")
if [ -z "$ZONE" ]; then
    echo "Could not find the zone of the cluster. Please check if the cluster exists."
    exit 1
fi

echo "Found zone for $DOMAIN_DASHED: $ZONE"

gcloud container clusters get-credentials $DOMAIN_DASHED --zone $ZONE --project $PROJECT --internal-ip

# test if we get a response from the cluster
echo "Testing if we can connect to the cluster..."
kubectl get pods --namespace sharedsvc
echo "Success!"

echo "Connecting telepresence..."
telepresence connect
echo "Checking if we can resolve the traffic-manager..."
nslookup traffic-manager.ambassador
echo "All set!"
