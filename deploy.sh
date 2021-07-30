#!/usr/bin/env bash

PROJECT=$1
WORKSPACE=${WORKSPACE:-'.'}

pushd ${WORKSPACE}

if [ -z "$PROJECT" ]; then
	echo "ERROR: Project not supplied"
	exit 1
fi

if [ "$PROJECT" == "ogm" ]; then
	ADDITIONAL_OPTIONS="-DmongodbProvider=external -DskipITs"
else
	ADDITIONAL_OPTIONS=""
fi

source $WORKSPACE/hibernate-noorm-release-scripts/mvn-setup.sh

./mvnw -Pdocbook,documentation-pdf,dist,perf,relocation,release clean deploy -DskipTests=true -Dcheckstyle.skip=true -DperformRelease=true -Dmaven.compiler.useIncrementalCompilation=false $ADDITIONAL_OPTIONS

popd
