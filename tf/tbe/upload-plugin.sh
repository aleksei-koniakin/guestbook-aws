#!/bin/bash

set -e -u -x

V=1.0.3040

rm -rf tc-plugin || true
mkdir tc-plugin

rm -rf tc-plugin.zip || true


curl -o tc-plugin.zip https://buildserver.labs.intellij.net/guestAuth/repository/downloadAll/TBE_BuildAggregator/$V 

cd tc-plugin && unzip ../tc-plugin

ls -lah tc-pluigin

