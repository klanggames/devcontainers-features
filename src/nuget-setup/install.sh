#!/bin/bash
set -e

echo "Installing nuget-setup script..."

cat >/usr/local/bin/nuget-setup \
    <<EOF
    #!/bin/bash

    USER=\$1
    TOKEN=\$2

    if [ -z "\$USER" ] && [ -n "\$GITHUB_USER" ]; then
        USER="\$GITHUB_USER"
    fi

    if [ -z "\$USER" ]; then
        echo "Missing argument: user, either specify or set GITHUB_USER environment variable"
        exit 1
    fi

    if [ -z "\$TOKEN" ] && [ -n "\$GITHUB_TOKEN" ]; then
        TOKEN="\$GITHUB_TOKEN"
    fi

    if [ -z "\$TOKEN" ]; then
        echo "Missing argument: token, either specify or set GITHUB_TOKEN environment variable"
        exit 1
    fi

    REGISTRY="https://npm.pkg.github.com/@klanggames"
    CONTENT="[npmAuth.\"\$REGISTRY\"]
    token = \"\$TOKEN\"
    email = \"\$EMAIL\"
    alwaysAuth = true"
    echo "\$CONTENT" >"\$HOME/.upmconfig.toml"

    if ! dotnet nuget list source | grep -q 'https://nuget.pkg.github.com/klanggames/index.json'; then
        dotnet nuget add source --username "\$USER" --password "\$TOKEN" --store-password-in-clear-text --name github "https://nuget.pkg.github.com/klanggames/index.json"
    else
        dotnet nuget update source github --source https://nuget.pkg.github.com/klanggames/index.json --username "\$USER" --password "\$TOKEN" --store-password-in-clear-text
    fi

EOF

chmod +x /usr/local/bin/nuget-setup
