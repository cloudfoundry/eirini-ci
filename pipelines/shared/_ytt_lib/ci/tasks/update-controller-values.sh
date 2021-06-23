#!/bin/bash

values_path=$(readlink -f "eirini-controller-built/deployment/helm/values.yaml")

pushd state-modified
{
  mkdir -p eirini-controller
  cp "$values_path" eirini-controller/values.yml
}
popd
