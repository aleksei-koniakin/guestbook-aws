#!/bin/bash

set -e -x -u

### Our setup uses this SSH host to do the actual images
### Download/Uploading. We assume it has credentials to
### Space Package Repository of Toolbox Enterprise
### Change this host to another machine if needed.
H=munit-182.labs.intellij.net


export AWS_PROFILE=guestbook
V=1.0.3046
R="ssh $H " 

aws ecr get-login-password --region us-west-2 | $R docker login --username AWS --password-stdin 920267453440.dkr.ecr.us-west-2.amazonaws.com

C="registry.jetbrains.team/p/toolbox-enterprise/containers/tbe-server:$V"
CC="920267453440.dkr.ecr.us-west-2.amazonaws.com/tbe-server:$V"

$R docker pull $C
$R docker tag $C $CC
$R docker push $CC




