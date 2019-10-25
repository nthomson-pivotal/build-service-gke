#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

github_token=$1

if [ -z "$github_token" ]; then
  echo "Error: you must provide a GitHub token"
  exit 1
fi

kubectl -n spinnaker exec spinnaker-spinnaker-halyard-0 -- bash -c "echo '$github_token' > /tmp/github_token.txt && \
    hal config artifact github enable && \
    hal config artifact github account add github-account \
    --token-file /tmp/github_token.txt && hal deploy apply"