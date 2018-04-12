#!/usr/bin/env bash

# See utils.sh
source $(readlink -f ${BASH_SOURCE[0]} | xargs dirname)/utils.sh

# Using /dev/null as input to just test connection, we don't want to execute anything
try_multiple_times sftp -b /dev/null frs.sourceforge.net || (echo "SourceForge not available at the moment. Try again later."; exit 1)
