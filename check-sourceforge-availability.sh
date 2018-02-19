#!/usr/bin/env bash

((echo quit) | sftp -b - frs.sourceforge.net ) || (echo "SourceForge not available at the moment. Try again later."; exit 1)
