FROM debian:latest

RUN apt-get update && \
    apt-get install --yes \
      apt-transport-https \
      bash \
      ca-certificates \
      curl \
      git

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

# helm
RUN wget --quiet https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz && tar xfz helm-v2.9.1-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/ && chmod +x /usr/bin/helm

# goml
RUN wget --quiet --output-document /usr/bin/goml https://github.com/JulzDiverse/goml/releases/download/v0.4.0/goml-linux-amd64 && chmod +x /usr/bin/goml
