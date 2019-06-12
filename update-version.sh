#!/usr/bin/env bash

PROJECT=$1
NEW_VERSION=$2
# If set, Project version is inherited from parent (maven requires a different command)
VERSION_INHERITED=$3
WORKSPACE=${WORKSPACE:-'.'}
SETTINGS_XML=${SETTINGS_XML:-$HOME'/.m2/settings-search-release.xml'}

if [ -z "$PROJECT" ]; then
	echo "ERROR: Project not supplied"
	exit 1
fi
if [ -z "$NEW_VERSION" ]; then
	echo "ERROR: New version argument not supplied"
	exit 1
else
	echo "Setting version to '$NEW_VERSION'";
fi

pushd $WORKSPACE
if [ -f bom/pom.xml ]; then
	./mvnw -s $SETTINGS_XML -Prelocation clean versions:set -DnewVersion=$NEW_VERSION -DgenerateBackupPoms=false -f bom/pom.xml
elif [ -z "$VERSION_INHERITED" ]; then
	./mvnw -s $SETTINGS_XML -Prelocation clean versions:set -DnewVersion=$NEW_VERSION -DgenerateBackupPoms=false
else
    # Version inherited from parent
    ./mvnw -s $SETTINGS_XML -Prelocation versions:update-parent -DparentVersion="[1.0, $NEW_VERSION]" -DgenerateBackupPoms=false -DallowSnapshots=true
    ./mvnw -s $SETTINGS_XML -Prelocation -N versions:update-child-modules -DgenerateBackupPoms=false
fi
popd
