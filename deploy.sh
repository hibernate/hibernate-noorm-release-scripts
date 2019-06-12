#!/usr/bin/env bash

PROJECT=$1
WORKSPACE=${WORKSPACE:-'.'}
SETTINGS_XML=${SETTINGS_XML:-$HOME'/.m2/settings-search-release.xml'}

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

./mvnw -s $SETTINGS_XML -Pdocbook,documentation-pdf,dist,perf,relocation,release clean deploy -s $HOME/.m2/settings-search-release.xml -DskipTests=true -Dcheckstyle.skip=true -DperformRelease=true -Dmaven.compiler.useIncrementalCompilation=false $ADDITIONAL_OPTIONS

popd
