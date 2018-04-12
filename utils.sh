#!/usr/bin/env bash
# To be sourced from other scripts. Tip: use the following line to source it independently from the PWD,
# provided your script is in the same directory as this one:
#     source $(readlink -f ${BASH_SOURCE[0]} | xargs dirname)/utils.sh

# Temporary hack, because sourceforge currently rejects connections randomly
function try_multiple_times() {
	local ERR
    local MAX_TRIES=5
    local COUNT=0
    while [ $COUNT -lt $MAX_TRIES ]
    do
       if [ $COUNT -ne 0 ]
       then
          echo "Retrying \"${@}\" (attempt #$(( COUNT + 1 )))..."
       fi
       "${@}"
       ERR=$?
       if [ $ERR -eq 0 ]
       then
          break
       fi
       COUNT=$(( COUNT + 1 ))
    done
    return $ERR
}