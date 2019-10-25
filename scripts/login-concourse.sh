#!/bin/bash

set -e

if ! [ -x "$(command -v fly)" ]; then
  echo 'Error: fly cli is not installed.' >&2
  exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

concourse_url=$(terraform output -state=$DIR/../terraform/terraform.tfstate concourse_url)
concourse_username=$(terraform output -state=$DIR/../terraform/terraform.tfstate concourse_user)
concourse_password=$(terraform output -state=$DIR/../terraform/terraform.tfstate concourse_password)

fly -t pbs login -c $concourse_url -u $concourse_username -p $concourse_password -n main