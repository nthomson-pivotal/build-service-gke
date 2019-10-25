#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

harbor_domain=$(terraform output -state=$DIR/../terraform/terraform.tfstate harbor_domain)
harbor_username=$(terraform output -state=$DIR/../terraform/terraform.tfstate harbor_admin_user)
harbor_password=$(terraform output -state=$DIR/../terraform/terraform.tfstate harbor_admin_password)

uaa_url=$(terraform output -state=$DIR/../terraform/terraform.tfstate uaa_url)

curl -i -X PUT -u "${harbor_username}:${harbor_password}" \
  -H "Content-Type: application/json" \
  https://${harbor_domain}/api/configurations \
  -d "{\"auth_mode\":\"oidc_auth\",\"oidc_client_id\":\"harbor-oidc\",\"oidc_client_secret\":\"abcd1234\",\"oidc_endpoint\":\"${uaa_url}:443/oauth/token\",\"oidc_name\":\"UAA\",\"oidc_scope\":\"openid,roles,uaa.user\"}"