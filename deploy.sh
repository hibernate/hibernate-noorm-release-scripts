#!/usr/bin/env bash

PROJECT=$1
WORKSPACE=${WORKSPACE:-'.'}

pushd ${WORKSPACE}

if [ -z "$PROJECT" ]; then
	echo "ERROR: Project not supplied"
	exit 1
fi

if [ "$PROJECT" == "ogm" ]; then
	ADDITIONAL_OPTIONS="-DmongodbProvider=external"
else
	ADDITIONAL_OPTIONS=""
fi

mvn -Pdocbook,documentation-pdf,dist,perf clean deploy -s $HOME/.m2/settings-search-release.xml -DskipTests=true -Dcheckstyle.skip=true -DperformRelease=true -Dmaven.compiler.useIncrementalCompilation=false $ADDITIONAL_OPTIONS

popd
