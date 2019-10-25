#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pbs_domain=$(terraform output -state=$DIR/../terraform/terraform.tfstate pbs_domain)

pb api set $pbs_domain --skip-ssl-validation