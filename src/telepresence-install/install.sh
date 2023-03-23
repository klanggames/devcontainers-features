#!/bin/bash
set -e

# install dependencies
echo "Installing dependencies..."
apt update && apt install -y --no-install-recommends \
    curl \
    dnsutils

# install telepresence
echo "Installing telepresence..."

if [ "$(uname -m)" = 'x86_64' ]; then echo -n "amd64" >/tmp/arch; else echo -n "arm64" >/tmp/arch; fi
ARCH=$(cat /tmp/arch)

URL="https://app.getambassador.io/download/tel2/linux/${ARCH}/${VERSION}/telepresence"
echo "Downloading ${URL}..."
curl -fL "${URL}" -o /usr/local/bin/telepresence
chmod a+x /usr/local/bin/telepresence

echo "Installing connect-telepresence script..."

cat >/usr/local/bin/connect-telepresence \
    <<EOF
    #!/bin/bash
    set -e

    # arguments that are:
    # --domain (required)
    # --project (defaults to "seed-209211" if not set)

    # parse arguments
    while [[ \$# -gt 0 ]]
    do
        key="\$1"
        case \$key in
            --domain)
                DOMAIN="\$2"
                shift
                shift
                ;;
            --project)
                PROJECT="\$2"
                shift
                shift
                ;;
            *)
                echo "Unknown argument: \$1"
                exit 1
                ;;
        esac
    done

    # check arguments
    if [ -z "\$DOMAIN" ]; then
        echo "Missing argument: --domain"
        exit 1
    fi

    # set defaults
    if [ -z "\$PROJECT" ]; then
        PROJECT="seed-209211"
    fi

    # replace "." in domain with "-"
    DOMAIN_DASHED=\$(echo "\$DOMAIN" | sed 's/\./-/g')

    # auth gcloud first, requires some user input
    echo "Authenticating gcloud..."
    echo "You will be asked to authenticate with your Google account twice."
    # set project
    gcloud config set project \$PROJECT
    # login if not already logged in (test if 'gcloud config get account' returns an email address)
    if ! gcloud config get account | grep -q "@"; then
        gcloud auth login
    fi
    # set application default credentials if not already set (test if 'gcloud auth application-default print-access-token' returns a token)
    if ! gcloud auth application-default print-access-token | grep -q "ya29"; then
        gcloud auth application-default login
    fi

    echo "Finding the zone of the cluster..."
    ZONE=\$(gcloud container clusters list --format json --project \$PROJECT | jq -r ".[] | select(.name == \"\$DOMAIN_DASHED\") | .zone")
    if [ -z "\$ZONE" ]; then
        echo "Could not find the zone of the cluster. Please check if the cluster exists."
        exit 1
    fi

    echo "Found zone for \$DOMAIN_DASHED: \$ZONE"

    gcloud container clusters get-credentials \$DOMAIN_DASHED --zone \$ZONE --project \$PROJECT --internal-ip

    # test if we get a response from the cluster
    echo "Testing if we can connect to the cluster..."
    kubectl get pods --namespace sharedsvc
    echo "Success!"

    echo "Connecting telepresence..."
    telepresence connect
    echo "Checking if we can resolve the traffic-manager..."
    nslookup traffic-manager.ambassador
    echo "All set!"
EOF

chmod +x /usr/local/bin/connect-telepresence

cat >/usr/local/bin/get-env \
    <<EOF
    #!/bin/bash

    set -- \$(getopt -n "\$0" -o n:w: --long namespace:,workload: -- \$@)

    # extract options and their arguments into variables.
    while true ; do
        case "\$1" in
            -n|--namespace) namespace=\$2 ; shift 2 ;;
            -w|--workload) workload=\$2 ; shift 2 ;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    # trim arguments
    workload=\$(echo \$workload | tr -d "'" | tr -d '"')
    namespace=\$(echo \$namespace | tr -d "'" | tr -d '"')

    # check if namespace and workload are set
    if [ -z "\$workload" ] || [ -z "\$namespace" ]
    then
        echo "Usage: source \$0 -n <namespace> -w <workload>"
        exit 1
    fi

    # get pod from workload name and namesapce
    pod=\$(kubectl get pods -n \$namespace -l app=\$workload -o jsonpath='{.items[0].metadata.name}')
    env=\$(kubectl -n \$namespace exec \$pod -- printenv | grep -v "HOME" | grep -v "PATH")

    envarray=(\$env)

    echo exporting environment variables from \$workload in \$namespace:

    # export each environment variable
    for line in "\${envarray[@]}"; do
        echo \$line
        export \$line
    done

EOF

chmod +x /usr/local/bin/get-env
