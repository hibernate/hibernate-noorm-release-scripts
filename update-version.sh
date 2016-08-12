#!/usr/bin/env bash

PROJECT=$1
NEW_VERSION=$2
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
	mvn clean versions:set -DnewVersion=$NEW_VERSION -DgenerateBackupPoms=false -f bom/pom.xml
else
	mvn clean versions:set -DnewVersion=$NEW_VERSION -DgenerateBackupPoms=false
fi
popd
