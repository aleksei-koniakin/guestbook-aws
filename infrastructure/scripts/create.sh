#!/usr/bin/env bash
set -e

if [[ -z $AWS_PATH ]]; then
  AWS_PATH=$(which aws)
fi

# Set working directory to be the script's directory
cd "$(dirname "${BASH_SOURCE[0]}")"

# Usage: create.sh [workspace to create]
if [[ -z $1 ]]; then
  echo "Usage: $0 [name of the workspace to create]"
  exit 1
fi

workspace=$1
if [[ $workspace == "master" ]] || [[ $workspace == "default" ]]; then
  # This needs to use the 'prod-*' terraform configs
  echo "Use the prod terraform folders directly, can't create a new default/master environment"
  exit 1
fi

# Go to project root
cd ../../

count=$(cat tf/staging-env/locals.tf | grep ${workspace} | wc -l)
if [[ $count -lt 1 ]]; then
  echo "Please define a subnet for this environment in tf/staging-env/locals.tf"
  exit 1
fi

# Let's ensure we can connect to the database, we'll need it
export PGHOST="${PGHOST:-db.guestbook.teamcity.com}"
export PGPORT="${PGPORT:-5432}"
export PGUSER="${PGUSER:-jetbrains}"
export PGPASSWORD="$($AWS_PATH secretsmanager get-secret-value --secret-id guestbook/db/master | jq -r '.SecretString')"

# This will exit with code 1 if it ain't
pg_isready

echo "Creating workspace ${workspace}..."

# Initialize the environment
cd tf/staging-env
terraform init
terraform workspace new $workspace
terraform apply -auto-approve

export PGDATABASE="$(terraform output -json db_name | jq -r '.')"
export GRANT_TO="$(terraform output -json db_user | jq -r '.')"

cd ../../

# Now connect to the DB and set up the new database
psql -f database/schema.sql
psql -f database/grant.sql -v username=${GRANT_TO}

# Initialize the application

cd tf/staging-app
terraform init
terraform workspace new $workspace
terraform apply -auto-approve
