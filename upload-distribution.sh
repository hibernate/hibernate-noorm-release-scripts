#!/usr/bin/env -S bash -e

SCRIPTS_DIR="$(readlink -f ${BASH_SOURCE[0]} | xargs dirname)"

source "$SCRIPTS_DIR/utils.sh"

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

# Storing the script in a file is necessary to be able to execute the sftp command in "try_multiple_times"
CREATE_DIR_SFTP_SCRIPT=$(mktemp)
cat >$CREATE_DIR_SFTP_SCRIPT <<EOF
mkdir $REMOTE_DIST_PARENT_DIR/$RELEASE_VERSION
quit
EOF
try_multiple_times sftp -b $CREATE_DIR_SFTP_SCRIPT hibernate-ci@frs.sourceforge.net || echo "Directory already exists. Skipping creation."
rm $CREATE_DIR_SFTP_SCRIPT

REMOTE_DIST_URL=hibernate-ci@frs.sourceforge.net:$REMOTE_DIST_PARENT_DIR/$RELEASE_VERSION/

try_multiple_times scp -v README.md $REMOTE_DIST_URL
try_multiple_times scp -v changelog.txt $REMOTE_DIST_URL

# Recursive upload of the dist directory (whose content is project-specific)
DIST_DIR=distribution/target/dist
if [ -d $DIST_DIR ]; then
	# Cd to the dist directory to prevent scp from uploading a "dist" directory
	pushd $DIST_DIR
	try_multiple_times scp -v -r . $REMOTE_DIST_URL
	popd
fi

# Legacy behavior with explicit uploads - useful for older branches
LEGACY_DIST_ZIP=distribution/target/hibernate-$PROJECT-$RELEASE_VERSION-dist.zip
if [ -f $LEGACY_DIST_ZIP ]; then
	try_multiple_times scp $LEGACY_DIST_ZIP $REMOTE_DIST_URL
fi
LEGACY_DIST_TAR=distribution/target/hibernate-$PROJECT-$RELEASE_VERSION-dist.tar.gz
if [ -f $LEGACY_DIST_TAR ]; then
	try_multiple_times scp $LEGACY_DIST_TAR $REMOTE_DIST_URL
fi
LEGACY_MODULE=modules/target/hibernate-$PROJECT-modules-$RELEASE_VERSION-wildfly-10-dist.zip
if [ -f $LEGACY_MODULE ]; then
	try_multiple_times scp $LEGACY_MODULE $REMOTE_DIST_URL
fi

popd

echo "Distribution uploaded to SourceForge"
