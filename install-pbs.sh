#!/bin/bash

set -e

PBS_VERSION=0.0.3

pivnet_token=$1
dockerhub_username=$2
dockerhub_password=$3

if ! [ -x "$(command -v pivnet)" ]; then
  echo 'Error: pivnet cli is not installed.' >&2
  exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OS_TYPE="darwin"

WORK_DIR=$DIR/work
BIN_DIR=$WORK_DIR/bin
DATA_DIR=$WORK_DIR/data
DUFFLE_GLOB=duffle-$PBS_VERSION-$OS_TYPE
DUFFLE=$BIN_DIR/$DUFFLE_GLOB
PB_GLOB=pb-$PBS_VERSION-$OS_TYPE
PB=$BIN_DIR/$PB_GLOB
PBS_GLOB=build-service-$PBS_VERSION.tgz
PBS_ARCHIVE=$WORK_DIR/$PBS_GLOB
PBS_IMPORT=$WORK_DIR/build-service

if [ ! -d "$BIN_DIR" ]; then
  mkdir -p $BIN_DIR
fi

if [ ! -d "$DATA_DIR" ]; then
  mkdir -p $DATA_DIR
fi

if [ ! -f $DUFFLE ]; then
  echo "Downloading duffle cli..."
  pivnet download-product-files -p build-service -r $PBS_VERSION -g $DUFFLE_GLOB -d $BIN_DIR

  chmod +x $DUFFLE
fi

if [ ! -f $PB ]; then
  echo "Downloading pb cli..."
  pivnet download-product-files -p build-service -r $PBS_VERSION -g $PB_GLOB -d $BIN_DIR

  chmod +x $PB
fi

if [ ! -f $PBS_ARCHIVE ]; then
  echo "Downloading pbs archive..."
  pivnet download-product-files -p build-service -r $PBS_VERSION -g $PBS_GLOB -d $WORK_DIR
fi

if [ ! -d $PBS_IMPORT ]; then
  echo "duffle importing pbs archive..."
  $DUFFLE import $PBS_ARCHIVE -d $PBS_IMPORT
fi

harbor_domain=$(terraform output -state=$DIR/terraform/terraform.tfstate harbor_domain)
harbor_username=$(terraform output -state=$DIR/terraform/terraform.tfstate harbor_admin_user)
harbor_password=$(terraform output -state=$DIR/terraform/terraform.tfstate harbor_admin_password)

if [ ! -f $DATA_DIR/relocated.json ]; then
  echo "duffle relocating pbs archive..."
  duffle relocate -f $PBS_ARCHIVE -m $DATA_DIR/relocated.json -p nthomsonpivotal
fi

touch $DATA_DIR/fake-ca.crt

cat << EOF > $DATA_DIR/pbs-test-team.yml
name: test-team
registries:
- registry: $harbor_domain
  username: $harbor_username
  password: $harbor_password
EOF

cat << EOF > $DATA_DIR/pbs-cellr-backend-image.yml
team: test-team
source:
  git:
    url: https://github.com/nthomson-pivotal/cellr-backend
    revision: master
build:
  env: []
image:
  tag: $harbor_domain/library/cellr-backend
EOF

kubectl get secret wildcard-tls-secret -n default -o json | jq -r 'del(.data["ca.crt"]) | del(.metadata) | .metadata.namespace = "default" | .metadata.name = "build-service-certificate" | .type = "Opaque"' | kubectl apply -f -

if [ ! -f $DATA_DIR/credentials.yml ]; then
  (cd $DATA_DIR && $DIR/scripts/get-kubeconfig.sh)

  kubectl get secret wildcard-tls-secret -n default -o json | jq -r '.data["tls.crt"]' | base64 -D > $DATA_DIR/tls.crt
  kubectl get secret wildcard-tls-secret -n default -o json | jq -r '.data["tls.key"]' | base64 -D > $DATA_DIR/tls.key

  cat << EOF > $DATA_DIR/credentials.yml
name: build-service-credentials
credentials:
  - name: kube_config
    source:
      path: "$DATA_DIR/build/kubeconfig"
    destination:
      path: "/root/.kube/config"
  - name: ca_cert
    source:
      path: "$DATA_DIR/fake-ca.crt"
    destination:
      path: "/cnab/app/cert/ca.crt"
  - name: tls_cert
    source:
      path: "$DATA_DIR/tls.crt"
    destination:
      path: "/cnab/app/cert/tls.crt"
  - name: tls_key
    source:
      path: "$DATA_DIR/tls.key"
    destination:
      path: "/cnab/app/cert/tls.key"
EOF
fi

uaa_url=$(terraform output -state=$DIR/terraform/terraform.tfstate uaa_url)

pbs_domain=$(terraform output -state=$DIR/terraform/terraform.tfstate pbs_domain)

echo "Running duffle install..."

$DUFFLE install build-service-qs -c $DATA_DIR/credentials.yml \
    --set domain=$pbs_domain \
    --set kubernetes_env=k8s \
    --set docker_registry=index.docker.io \
    --set registry_username=$dockerhub_username \
    --set registry_password=$dockerhub_password \
    --set uaa_url=$uaa_url \
    -f $PBS_ARCHIVE \
    -m $DATA_DIR/relocated.json

sleep 30

$DIR/scripts/login-pbs.sh

echo ""
echo "Pivotal Build Service has been successfully installed, you can login with UAA credentials"
