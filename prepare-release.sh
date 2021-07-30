#!/usr/bin/env bash

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

pushd "$SCRIPTS_DIR"
bundle install
popd

pushd $WORKSPACE

bash "$SCRIPTS_DIR/check-sourceforge-availability.sh"
"$SCRIPTS_DIR/pre-release.rb" -p $PROJECT -v $RELEASE_VERSION -r $WORKSPACE/README.md -c $WORKSPACE/changelog.txt
bash "$SCRIPTS_DIR/validate-release.sh" $PROJECT $RELEASE_VERSION
bash "$SCRIPTS_DIR/update-version.sh" $PROJECT $RELEASE_VERSION $INHERITED_VERSION
bash "$SCRIPTS_DIR/create-tag.sh" $PROJECT $RELEASE_VERSION

popd

echo "Release ready: version is updated to $RELEASE_VERSION"
