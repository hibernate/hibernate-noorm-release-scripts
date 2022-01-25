#!/usr/bin/env -S bash -e

function usage() {
  echo "Usage:"
  echo
  echo "  $0 [options] <project> <release_version> <development_version>"
  echo
  echo "    <project>                One of [search,validator,ogm]"
  echo "    <release_version>        The version to release (e.g. 6.0.0.Final)"
  echo "    <development_version>    The new version after the release (e.g. 6.0.1-SNAPSHOT)"
  echo
  echo "  Options"
  echo
  echo "    -h            Show this help and exit."
  echo "    -b <branch>   The branch to push to (e.g. main or 6.0)."
  echo "                  Defaults to the name of the current branch."
  echo "    -d            Dry run; do not push, deploy or publish anything."
}

#--------------------------------------------
# Option parsing

function exec_or_dry_run() {
  "${@}"
}
PUSH_CHANGES=true

while getopts 'dhb:' opt; do
  case "$opt" in
  b)
    BRANCH="$OPTARG"
    ;;
  h)
    usage
    exit 0
    ;;
  d)
    # Dry run
    echo "DRY RUN: will not push/deploy/publish anything."
    PUSH_CHANGES=false
    function exec_or_dry_run() {
      echo "DRY RUN; would have executed:" "${@}"
    }
    ;;
  \?)
    usage
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

WORKSPACE="${WORKSPACE:-'.'}"
SCRIPTS_DIR="$(readlink -f ${BASH_SOURCE[0]} | xargs dirname)"
PROJECT="$1"
if [ -z "$PROJECT" ]; then
  echo "ERROR: Project not supplied"
  usage
  exit 1
fi
shift
RELEASE_VERSION="$1"
if [ -z "$RELEASE_VERSION" ]; then
  echo "ERROR: Release version not supplied"
  usage
  exit 1
fi
shift
DEVELOPMENT_VERSION="$1"
if [ -z "$DEVELOPMENT_VERSION" ]; then
  echo "ERROR: Development version not supplied"
  usage
  exit 1
fi
shift

#--------------------------------------------
# Defaults / computed

if [ -z "$BRANCH" ]; then
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  echo "Inferred release branch: $BRANCH"
fi
if (( $# > 0 )); then
  echo "ERROR: Extra arguments:" "${@}"
  usage
  exit 1
fi

RELEASE_VERSION_FAMILY=$(echo "$RELEASE_VERSION" | sed -E 's/^([0-9]+\.[0-9]+).*/\1/')

if [ "$RELEASE_VERSION" = "$RELEASE_VERSION_FAMILY" ]; then
  echo "ERROR: Could not extract family from release version $RELEASE_VERSION"
  usage
  exit 1
else
  echo "Inferred release version family: $RELEASE_VERSION_FAMILY"
fi

#--------------------------------------------
# Environment variables

if [ -z "$RELEASE_GPG_HOMEDIR" ]; then
  echo "ERROR: environment variable RELEASE_GPG_HOMEDIR is not set"
  exit 1
fi
if [ -z "$RELEASE_GPG_PRIVATE_KEY_PATH" ]; then
  echo "ERROR: environment variable RELEASE_GPG_PRIVATE_KEY_PATH is not set"
  exit 1
fi

#--------------------------------------------
# Cleanup on exit

function cleanup() {
  if [ -n "$IMPORTED_KEY" ]; then
    echo "Deleting imported GPG private key..."
    gpg --homedir="$RELEASE_GPG_HOMEDIR" --batch --yes --delete-secret-keys "$IMPORTED_KEY" || true
  fi
  if [ -d "$RELEASE_GPG_HOMEDIR" ]; then
    echo "Cleaning up GPG homedir..."
    rm -rf "$RELEASE_GPG_HOMEDIR" || true
    echo "Clearing GPG agent..."
    gpg-connect-agent reloadagent /bye || true
  fi
}

trap "cleanup" EXIT

#--------------------------------------------
# Actual script

if [ -e "$RELEASE_GPG_HOMEDIR" ]; then
  echo "ERROR: temporary gpg homedir '$RELEASE_GPG_HOMEDIR' must not exist"
  exit 1
fi
mkdir -p -m 700 "$RELEASE_GPG_HOMEDIR"
IMPORTED_KEY="$(gpg --homedir="$RELEASE_GPG_HOMEDIR" --batch --import "$RELEASE_GPG_PRIVATE_KEY_PATH" 2>&1 | tee /dev/stderr | grep 'key.*: secret key imported' | sed -E 's/.*key ([^:]+):.*/\1/')"
if [ -z "$IMPORTED_KEY" ]; then
  echo "Failed to import GPG key"
  exit 1
fi

bash -xe "$SCRIPTS_DIR/prepare-release.sh" "$PROJECT" "$RELEASE_VERSION"

bash -xe "$SCRIPTS_DIR/deploy.sh" "$PROJECT"

exec_or_dry_run bash -xe "$SCRIPTS_DIR/upload-distribution.sh" "$PROJECT" "$RELEASE_VERSION"
exec_or_dry_run bash -xe "$SCRIPTS_DIR/upload-documentation.sh" "$PROJECT" "$RELEASE_VERSION" "$RELEASE_VERSION_FAMILY"

bash -xe "$SCRIPTS_DIR/update-version.sh" "$PROJECT" "$DEVELOPMENT_VERSION"
bash -xe "$SCRIPTS_DIR/push-upstream.sh" "$PROJECT" "$RELEASE_VERSION" "$BRANCH_NAME" "$PUSH_CHANGES"
