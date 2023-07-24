#!/usr/bin/env bash
set -e

if [[ -z $AWS_PATH ]]; then
  AWS_PATH=$(which aws)
fi

# Usage: destroy.sh [workspace to destroy]
if [[ -z $1 ]]; then
  echo "Usage: $0 [name of the workspace to destroy]"
  exit 1
fi

workspace=$1
if [[ $workspace == "master" ]] || [[ $workspace == "default" ]]; then
  # This needs to use the 'prod-*' terraform configs
  echo "Can't destroy master or default workspaces"
  exit 1
fi

# Make sure that we can connect to the DB
export PGHOST="${PGHOST:-db.guestbook.teamcity.com}"
export PGPORT="${PGPORT:-5432}"

# These override the ones that the postgresql provisioner uses
# If a less-privileged user is configured, the script will fail
unset PGDATABASE
unset PGUSER
unset PGPASSWORD

pg_isready

echo "Destroying workspace ${workspace}..."

# Set working directory to be the script's directory
cd "$(dirname "${BASH_SOURCE[0]}")"

# Go to project root
cd ../../

# Verify that cloud debugging has been disabled
cd tf/staging-env
terraform init
terraform workspace select $workspace
CLUSTER_ARN=$(terraform output -json ecs_cluster_id | jq -r '.')
CLOUD_DEBUG=$(${AWS_PATH} ecs list-services --cluster ${CLUSTER_ARN} | grep "cloud-debug" | wc -l)

if [[ $CLOUD_DEBUG -gt 0 ]]; then
  echo "Please disable cloud debug first"
  exit 1
fi

cd ../staging-app
terraform init
terraform workspace select $workspace
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $workspace

cd ../staging-env
terraform workspace select $workspace
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $workspace
