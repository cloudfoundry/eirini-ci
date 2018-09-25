# docker build . -t eirini/ibmcloud
# docker push eirini/ibmcloud

FROM golang:1.10.2

RUN apt-get update && \
    apt-get install --yes \
      apt-transport-https \
      bash \
      ca-certificates \
      curl \
      git \
      gnupg2 \
      jq \
      lsb-release \
      software-properties-common

# CF CLI
RUN curl --fail --silent --show-error --location https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -\
  && echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list \
  && apt-get update \
  && apt-get install cf-cli

# Docker
# Due to issue with the docker version used in this image, it needs to be donwgraded until this issue is resolved (https://github.com/docker/for-linux/issues/219#issuecomment-375199143)
RUN  curl --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && apt-key fingerprint 0EBFCD88 \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
  && apt-get update \
  && apt-get install -y docker-ce=17.09.1~ce-0~debian

# goml
RUN curl --fail --silent --show-error --location --output /usr/bin/goml https://github.com/JulzDiverse/goml/releases/download/v0.4.0/goml-linux-amd64 && chmod +x /usr/bin/goml

# helm
RUN curl --fail --silent --show-error --location --remote-name https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz && tar xfz helm-v2.9.1-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/ && chmod +x /usr/bin/helm

# IBMCloud CLI
# https://console.bluemix.net/docs/cli/reference/ibmcloud/download_cli.html#shell_install
RUN curl --fail --silent --show-error --location https://clis.ng.bluemix.net/install/linux | sh
# Disable automatic version checking because it breaks the scripts
RUN ibmcloud config --check-version=false
# https://console.bluemix.net/docs/containers/cs_cli_install.html
RUN ibmcloud plugin install container-service
# Enable bash completion for ibmcloud
RUN echo source /usr/local/ibmcloud/autocomplete/bash_autocomplete >> ~/.bashrc

# kubectl
RUN curl https://storage.googleapis.com/kubernetes-release/release/$(curl --silent https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl > /usr/bin/kubectl && chmod +x /usr/bin/kubectl

