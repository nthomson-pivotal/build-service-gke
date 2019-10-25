#!/bin/bash

set -e

if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker cli is not installed.' >&2
  exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

harbor_domain=$(terraform output -state=$DIR/../terraform/terraform.tfstate harbor_domain)
harbor_username=$(terraform output -state=$DIR/../terraform/terraform.tfstate harbor_admin_user)
harbor_password=$(terraform output -state=$DIR/../terraform/terraform.tfstate harbor_admin_password)

docker login $harbor_domain -u $harbor_username -p $harbor_password