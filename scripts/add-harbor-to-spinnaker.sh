#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

REPOSITORIES="library/cellr-backend"

harbor_domain=$(terraform output -state=$DIR/../terraform/terraform.tfstate harbor_domain)
harbor_username=$(terraform output -state=$DIR/../terraform/terraform.tfstate harbor_admin_user)
harbor_password=$(terraform output -state=$DIR/../terraform/terraform.tfstate harbor_admin_password)

kubectl -n spinnaker exec spinnaker-spinnaker-halyard-0 -- bash -c "hal config provider docker-registry account add harbor-registry \
    --address $harbor_domain \
    --repositories $REPOSITORIES \
    --username $harbor_username \
    --no-validate \
    --password-command 'echo $harbor_password' && hal deploy apply"