#!/usr/bin/env -S bash -e

WORKSPACE="${WORKSPACE:-'.'}"

if [ -z "$RELEASE_GPG_HOMEDIR" ]; then
  echo "ERROR: environment variable RELEASE_GPG_HOMEDIR is not set"
  exit 1
fi
if [ -z "$RELEASE_GPG_PRIVATE_KEY_PATH" ]; then
  echo "ERROR: environment variable RELEASE_GPG_PRIVATE_KEY_PATH is not set"
  exit 1
fi

if [ -e "$RELEASE_GPG_HOMEDIR" ]; then
  echo "ERROR: temporary gpg homedir '$RELEASE_GPG_HOMEDIR' must not exist"
  exit 1
fi

mkdir -p -m 700 "$RELEASE_GPG_HOMEDIR"

gpg --homedir="$RELEASE_GPG_HOMEDIR" --batch --import "$RELEASE_GPG_PRIVATE_KEY_PATH"
