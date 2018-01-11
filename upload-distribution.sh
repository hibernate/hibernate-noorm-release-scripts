#!/usr/bin/env bash

PROJECT=$1
RELEASE_VERSION=$2
DIST_PARENT_DIR=${3:-"/home/frs/project/hibernate/hibernate-$PROJECT"}
WORKSPACE=${WORKSPACE:-'.'}

if [ -z "$PROJECT" ]; then
	echo "ERROR: Project not supplied"
	exit 1
fi
if [ -z "$RELEASE_VERSION" ]; then
	echo "ERROR: Release version argument not supplied"
	exit 1
fi

echo "#####################################################"
echo "# Uploading Hibernate $PROJECT $RELEASE_VERSION on"
echo "# SourceForge: $DIST_PARENT_DIR"
echo "#####################################################"
echo "Workspace: $WORKSPACE"

pushd $WORKSPACE

((echo mkdir $DIST_PARENT_DIR/$RELEASE_VERSION; echo quit) | sftp -b - frs.sourceforge.net) || echo "Directory already exists. Skipping creation."

REMOTE_DIST_URL=frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION/

scp README.md $REMOTE_DIST_URL
scp changelog.txt $REMOTE_DIST_URL
scp distribution/target/hibernate-$PROJECT-$RELEASE_VERSION-dist.zip $REMOTE_DIST_URL
scp distribution/target/hibernate-$PROJECT-$RELEASE_VERSION-dist.tar.gz $REMOTE_DIST_URL

MODULE=modules/target/hibernate-$PROJECT-modules-$RELEASE_VERSION-wildfly-10-dist.zip
if [ -f $MODULE ]; then
	scp $MODULE $REMOTE_DIST_URL
fi

popd

echo "Distribution uploaded to SourceForge"
