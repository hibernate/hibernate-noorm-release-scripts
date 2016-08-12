#!/usr/bin/env bash

PROJECT=$1
RELEASE_VERSION=$2
BRANCH=$3
PUSH_CHANGES=${4:-false}

if [ -z "$PROJECT" ]; then
	echo "ERROR: Project not supplied"
	exit 1
fi
if [ -z "$RELEASE_VERSION" ]; then
	echo "ERROR: Release version argument not supplied"
	exit 1
fi
if [ -z "$BRANCH" ]; then
	echo "Branch not supplied"
	 exit 1
fi

git commit -a -m "[Jenkins release job] Preparing next development iteration"

if [ "$PUSH_CHANGES" = true ] ; then
	echo "Pushing changes to the upstream repository."
	git push origin $BRANCH
	git push origin $RELEASE_VERSION
fi
if [ "$PUSH_CHANGES" != true ] ; then
	echo "WARNING: Not pushing changes to the upstream repository."
fi
