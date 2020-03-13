#!/usr/bin/env bash

# 100 times push something different, curl it. After everything log it, run `cf app <>`
domain="scaletest.ci-envs.eirini.cf-app.com"
cd "$1" || exit 1

for i in {1..100}; do
  app_name="${PWD##*/}-$i"

  cf push "$app_name" -m 512M
  curl "https://${app_name}.${domain}" >/tmp/logs/"$app_name"
done

for i in {1..100}; do
  app_name="${PWD##*/}-$i"

  cf app "$app_name" >>/tmp/logs/"$app_name"
  cf logs --recent "$app_name" >>/tmp/logs/"$app_name"
done
