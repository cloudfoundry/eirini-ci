FROM debian:latest

RUN apt-get update && \
    apt-get install --yes \
      apt-transport-https \
      bash \
      ca-certificates \
      curl \
      git \
      jq \
      wget \
      vim \
  && rm -rf /var/lib/apt/lists/*

# IBMCloud CLI
# https://cloud.ibm.com/docs/cli/reference/ibmcloud?topic=cloud-cli-install-ibmcloud-cli#shell_install
RUN curl --fail --silent --show-error --location https://clis.cloud.ibm.com/install/linux | sh
# Disable automatic version checking because it breaks the scripts
RUN ibmcloud config --check-version=false
# https://cloud.ibm.com/docs/containers?topic=containers-cs_cli_install
RUN ibmcloud plugin install container-service
# Enable bash completion for ibmcloud
RUN echo source /usr/local/ibmcloud/autocomplete/bash_autocomplete >> ~/.bashrc

# kubectl
RUN curl https://storage.googleapis.com/kubernetes-release/release/$(curl --silent https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl > /usr/bin/kubectl && chmod +x /usr/bin/kubectl

# helm
RUN wget --quiet https://storage.googleapis.com/kubernetes-helm/helm-v2.15.2-linux-amd64.tar.gz && tar xfz helm-v2.15.2-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/ && chmod +x /usr/bin/helm

# hub
RUN wget --quiet https://github.com/github/hub/releases/download/v2.11.2/hub-linux-amd64-2.11.2.tgz && tar xfz hub-linux-amd64-2.11.2.tgz && mv hub-linux-amd64-2.11.2/bin/hub /usr/bin/hub && chmod +x /usr/bin/hub

# goml
RUN wget --quiet --output-document /usr/bin/goml https://github.com/JulzDiverse/goml/releases/download/v0.7.0/goml-linux-amd64 && chmod +x /usr/bin/goml

# calicoctl
RUN curl -O -L https://github.com/projectcalico/calicoctl/releases/download/v3.4.4/calicoctl-linux-amd64 && mv ./calicoctl-linux-amd64 /usr/bin/calicoctl && chmod +x /usr/bin/calicoctl
