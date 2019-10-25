#!/bin/bash

set -e

if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker cli is not installed.' >&2
  exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$DIR/login-docker.sh

harbor_domain=$(terraform output -state=$DIR/../terraform/terraform.tfstate harbor_domain)

docker pull busybox:1.31

docker tag busybox:1.31 $harbor_domain/library/cellr-backend:noop

docker push $harbor_domain/library/cellr-backend:noop