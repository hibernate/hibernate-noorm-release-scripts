#!/usr/bin/env bash

PROJECT=$1
NEW_VERSION=$2
# If set, Project version is inherited from parent (maven requires a different command)
VERSION_INHERITED=$3
WORKSPACE=${WORKSPACE:-'.'}

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
	mvn -Prelocation clean versions:set -DnewVersion=$NEW_VERSION -DgenerateBackupPoms=false -f bom/pom.xml
elif [ -z "$VERSION_INHERITED"]; then
	mvn -Prelocation clean versions:set -DnewVersion=$NEW_VERSION -DgenerateBackupPoms=false
else
    # Version inherited from parent
    mvn -Prelocation versions:update-parent "-DparentVersion=$NEW_VERSION" -DgenerateBackupPoms=false
    mvn -Prelocation -N versions:update-child-modules -DgenerateBackupPoms=false
fi
popd
