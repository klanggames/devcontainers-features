#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "execute command" bash -c "connect-telepresence --domain seed-dev --project seed-209211"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
