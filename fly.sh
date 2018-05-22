#!/bin/bash

readonly ALIAS=$1
readonly PIPELINE_NAME=$2
readonly PRIVATE_REPO=$3

PIPELINE_CONFIG_FILE=""

usage(){
  cat << EOF
    Pipeline not found, but you can set a eirini-pipeline using the following command:

    fly -t $ALIAS set-pipeline
	--pipeline $PIPELINE_NAME
	--config <PROVIDE>
	--var "kube_conf=\$(kubectl config view --flatten)"
        --load-vars-from $PRIVATE_REPO
EOF

  exit 1
}

detect_pipeline(){
	if [ "$PIPELINE_NAME" = "eirini-ci" ]; then
	  aviator -f aviator/eirini-ci.yml
	  PIPELINE_CONFIG_FILE=eirini-ci.yml
	elif [ "$PIPELINE_NAME" = "eirini-dev" ]; then
          PIPELINE_CONFIG_FILE=stubs/eirini-dev.yml
        else
	  usage
        fi
}

main(){
  detect_pipeline

  fly -t $ALIAS set-pipeline \
	--pipeline $PIPELINE_NAME \
	--config $PIPELINE_CONFIG_FILE \
	--var "kube_conf=$(kubectl config view --flatten)" \
        --load-vars-from $PRIVATE_REPO/concourse/env/${PIPELINE_NAME}.yml \
        --load-vars-from $PRIVATE_REPO/concourse/env/common.yml
}

main
