#!/bin/bash
set -e

echo "Installing nuget-setup script..."

cat >/usr/local/bin/nuget-setup \
    <<EOF
    #!/bin/bash

    function setup_nuget_source() {
        EMAIL=\$1
        TOKEN=\$2

        if [ -z "\$EMAIL" ]; then
            echo -n 'GitHub Email:'
            read -r EMAIL
        fi

        # Validate the email address
        if [[ ! (\$EMAIL =~ ^[a-zA-Z0-9_.+-]+@(([a-zA-Z0-9-]+\.)?[a-zA-Z]+\.)?klang-games\.com$) ]]; then
            echo "Not a valid @klang-games.com email. Try again!"
            exit 1
        fi

        if [ -z "\$TOKEN" ]; then
            echo -n 'GitHub Access Token:'
            read -r -s TOKEN
        fi

        REGISTRY="https://npm.pkg.github.com/@klanggames"
        CONTENT="[npmAuth.\"\$REGISTRY\"]
        token = \"\$TOKEN\"
        email = \"\$EMAIL\"
        alwaysAuth = true"
        echo "\$CONTENT" >"\$HOME/.upmconfig.toml"

        if ! dotnet nuget list source | grep -q 'https://nuget.pkg.github.com/klanggames/index.json'; then
            dotnet nuget add source --username "\$EMAIL" --password "\$TOKEN" --store-password-in-clear-text --name github "https://nuget.pkg.github.com/klanggames/index.json"
        else
            dotnet nuget update source github --source https://nuget.pkg.github.com/klanggames/index.json --username "\$EMAIL" --password "\$TOKEN" --store-password-in-clear-text
        fi

    }

    if [ -z "\${GITHUB_USER}" ] || [ -z "\${GITHUB_TOKEN}" ]; then
        setup_nuget_source \$@
    else
        setup_nuget_source \$GITHUB_USER \$GITHUB_TOKEN
    fi
EOF

chmod +x /usr/local/bin/nuget-setup
