#!/bin/bash

set -e

if ! [ -x "$(command -v uaac)" ]; then
  echo 'Error: uaac cli is not installed.' >&2
  exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

uaa_url=$(terraform output -state=$DIR/../terraform/terraform.tfstate uaa_url)
uaa_admin_client_id=$(terraform output -state=$DIR/../terraform/terraform.tfstate uaa_admin_client_id)
uaa_admin_client_secret=$(terraform output -state=$DIR/../terraform/terraform.tfstate uaa_admin_client_secret)

uaac target $uaa_url --skip-ssl-validation

uaac token client get $uaa_admin_client_id -s $uaa_admin_client_secret