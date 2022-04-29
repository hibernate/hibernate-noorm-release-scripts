#!/usr/bin/env -S bash -e

SCRIPTS_DIR="$(readlink -f ${BASH_SOURCE[0]} | xargs dirname)"

PROJECT=$1
RELEASE_VERSION=$2
INHERITED_VERSION=$3
WORKSPACE=${WORKSPACE:-'.'}

if [ -z "$PROJECT" ]; then
	echo "ERROR: Project not supplied"
	exit 1
fi
if [ -z "$RELEASE_VERSION" ]; then
	echo "ERROR: Release version argument not supplied"
	exit 1
else
	echo "Setting version to '$RELEASE_VERSION'";
fi

echo "Preparing the release ..."

pushd $WORKSPACE

# Set up git so that we can create commits
git config --local user.name "Hibernate CI"
git config --local user.email "ci@hibernate.org"

"$SCRIPTS_DIR/check-sourceforge-availability.sh"
"$SCRIPTS_DIR/update-readme.sh" $PROJECT $RELEASE_VERSION "$WORKSPACE/README.md"
"$SCRIPTS_DIR/update-changelog.sh" $PROJECT $RELEASE_VERSION "$WORKSPACE/changelog.txt"
"$SCRIPTS_DIR/validate-release.sh" $PROJECT $RELEASE_VERSION
"$SCRIPTS_DIR/update-version.sh" $PROJECT $RELEASE_VERSION $INHERITED_VERSION
"$SCRIPTS_DIR/create-tag.sh" $PROJECT $RELEASE_VERSION

popd

echo "Release ready: version is updated to $RELEASE_VERSION"
