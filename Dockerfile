FROM golang:1.10.2

ENV PATH="$GOPATH/bin:${PATH}"

RUN apt-get update && \
    apt-get install --yes \
      apt-transport-https \
      ca-certificates \
      curl \
      git \
      gnupg2 \
      ruby \
      software-properties-common \
      wget

RUN echo "gem: --no-rdoc --no-ri" > ~/.gemrc

RUN gem install bundler

RUN wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64.zip && \
    unzip spiff_linux_amd64.zip && mv spiff /usr/local/bin/ && rm spiff_linux_amd64.zip

# Docker
RUN  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && apt-key fingerprint 0EBFCD88 \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
  && apt-get update \
  && apt-get install -y docker-ce

# bosh2
RUN wget --quiet https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-3.0.1-linux-amd64 --output-document /usr/bin/bosh && chmod +x /usr/bin/bosh

# kubectl
RUN wget --quiet https://storage.googleapis.com/kubernetes-release/release/$(curl --silent https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl --output-document /usr/bin/kubectl && chmod +x /usr/bin/kubectl

# ginkgo
RUN go get github.com/onsi/ginkgo/ginkgo
RUN go get github.com/onsi/gomega/...

# helm
RUN wget --quiet https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz && tar xfz helm-v2.9.1-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/ && chmod +x /usr/bin/helm

# goml
RUN wget --quiet --output-document /usr/bin/goml https://github.com/JulzDiverse/goml/releases/download/v0.4.0/goml-linux-amd64 && chmod +x /usr/bin/goml

# https://console.bluemix.net/docs/cli/reference/ibmcloud/download_cli.html#shell_install
RUN curl -fsSL https://clis.ng.bluemix.net/install/linux | sh

# Disable automatic version checking because it breaks the scripts
RUN ibmcloud config --check-version=false

# https://console.bluemix.net/docs/containers/cs_cli_install.html
RUN ibmcloud plugin install container-service

# Enable bash completion for ibmcloud
RUN echo source /usr/local/ibmcloud/autocomplete/bash_autocomplete >> ~/.bashrc


