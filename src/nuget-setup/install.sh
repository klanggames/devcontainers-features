#!/bin/bash
set -e

function setup_nuget_source() {
    EMAIL=$1
    TOKEN=$2


    REGISTRY="https://npm.pkg.github.com/@klanggames"
    CONTENT="[npmAuth.\"$REGISTRY\"]
    token = \"$TOKEN\"
    email = \"$EMAIL\"
    alwaysAuth = true"
    echo "$CONTENT" >"$HOME/.upmconfig.toml"

    if ! dotnet nuget list source | grep -q 'https://nuget.pkg.github.com/klanggames/index.json'; then
        dotnet nuget add source --username "$EMAIL" --password "$TOKEN" --store-password-in-clear-text --name github "https://nuget.pkg.github.com/klanggames/index.json"
    else
        dotnet nuget update source github --source https://nuget.pkg.github.com/klanggames/index.json --username "$EMAIL" --password "$TOKEN" --store-password-in-clear-text
    fi

}

setup_nuget_source $GITHUB_USER $GITHUB_TOKEN