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

(echo mkdir $DIST_PARENT_DIR/$RELEASE_VERSION; echo quit) | sftp -b - frs.sourceforge.net
scp README.md frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION
scp changelog.txt frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION
scp distribution/target/hibernate-$PROJECT-$RELEASE_VERSION-dist.zip frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION
scp distribution/target/hibernate-$PROJECT-$RELEASE_VERSION-dist.tar.gz frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION

MODULE=modules/target/hibernate-$PROJECT-modules-$RELEASE_VERSION-wildfly-10-dist.zip
if [ -f $MODULE ]; then
	scp $MODULE frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION
fi

echo "Distribution uploaded to SourceForge"
