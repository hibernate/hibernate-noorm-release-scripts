#!/usr/bin/env bash

PROJECT=$1
RELEASE_VERSION=$2
REMOTE_DIST_PARENT_DIR=${3:-"/home/frs/project/hibernate/hibernate-$PROJECT"}
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
echo "# SourceForge: $REMOTE_DIST_PARENT_DIR"
echo "#####################################################"
echo "Workspace: $WORKSPACE"

pushd $WORKSPACE

((echo mkdir $REMOTE_DIST_PARENT_DIR/$RELEASE_VERSION; echo quit) | sftp -b - frs.sourceforge.net) || echo "Directory already exists. Skipping creation."

REMOTE_DIST_URL=frs.sourceforge.net:$REMOTE_DIST_PARENT_DIR/$RELEASE_VERSION/

scp README.md $REMOTE_DIST_URL
scp changelog.txt $REMOTE_DIST_URL

# Recursive upload of the dist directory (whose content is project-specific)
DIST_DIR=distribution/target/dist
if [ -d $DIST_DIR ]; then
	# Cd to the dist directory to prevent scp from uploading a "dist" directory
	pushd $DIST_DIR
	scp -r . $REMOTE_DIST_URL
	popd
fi

# Legacy behavior with explicit uploads - useful for older branches
LEGACY_DIST_ZIP=distribution/target/hibernate-$PROJECT-$RELEASE_VERSION-dist.zip
if [ -f $LEGACY_DIST_ZIP ]; then
	scp $LEGACY_DIST_ZIP $REMOTE_DIST_URL
fi
LEGACY_DIST_TAR=distribution/target/hibernate-$PROJECT-$RELEASE_VERSION-dist.tar.gz
if [ -f $LEGACY_DIST_TAR ]; then
	scp $LEGACY_DIST_TAR $REMOTE_DIST_URL
fi
LEGACY_MODULE=modules/target/hibernate-$PROJECT-modules-$RELEASE_VERSION-wildfly-10-dist.zip
if [ -f $LEGACY_MODULE ]; then
	scp $LEGACY_MODULE $REMOTE_DIST_URL
fi

popd

echo "Distribution uploaded to SourceForge"
