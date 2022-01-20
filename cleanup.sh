#!/usr/bin/env -S bash -e

WORKSPACE="${WORKSPACE:-'.'}"

if [ -d "$RELEASE_GPG_HOMEDIR" ]; then
  echo "Cleaning up GPG homedir..."
  rm -rf "$RELEASE_GPG_HOMEDIR" || true
  echo "Clearing GPG agent..."
  gpg-connect-agent reloadagent /bye || true
fi
