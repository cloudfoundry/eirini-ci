FROM golang:latest

ARG BUILDKIT_CLI_VERSION="v0.1.5"
ARG KBLD_VERSION="v0.33.0"

ENV PATH="$GOPATH/bin:${PATH}"

RUN  apt-get update \
  && apt-get install --yes \
       --no-install-recommends \
       apt-transport-https \
       ca-certificates \
       curl \
       git \
       wget \
       jq \
       shellcheck \
       software-properties-common \
       lsb-release \
       unzip \
       vim \
       apt-transport-https \
       gnupg2 \
       sshfs \
       conntrack \
       iptables \
       sudo \
  && rm -rf /var/lib/apt/lists/*

# telepresence
RUN curl -s https://packagecloud.io/install/repositories/datawireio/telepresence/script.deb.sh | os=debian dist=buster bash
RUN apt install -y --no-install-recommends telepresence

# kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl

# CF CLI
RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
RUN echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
RUN sudo apt-get update && sudo apt-get install -y cf7-cli

# ginkgo && shfmt
RUN go install github.com/onsi/ginkgo/v2/ginkgo@latest
RUN go install mvdan.cc/sh/cmd/shfmt@latest

# goml
RUN wget --quiet --output-document /usr/bin/goml https://github.com/JulzDiverse/goml/releases/download/v0.7.0/goml-linux-amd64 && chmod +x /usr/bin/goml

# yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
  && sudo apt update \
  && sudo apt install -y yarn

# yq
RUN curl -sLo yq https://github.com/mikefarah/yq/releases/download/v4.6.2/yq_linux_amd64 \
  && install yq /usr/bin/ \
  && rm -f yq

# gh cli
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 \
  && apt-add-repository https://cli.github.com/packages \
  && apt update \
  && apt install gh

# helm
RUN wget --quiet https://get.helm.sh/helm-v3.5.3-linux-amd64.tar.gz && tar xfz helm-v3.5.3-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/ && chmod +x /usr/bin/helm

# kbld
RUN curl -sL "https://github.com/vmware-tanzu/carvel-kbld/releases/download/${KBLD_VERSION}/kbld-linux-amd64" -o /usr/local/bin/kbld && \
  chmod +x /usr/local/bin/kbld

# buildkit kubectl cli
RUN curl -sL https://github.com/vmware-tanzu/buildkit-cli-for-kubectl/releases/download/${BUILDKIT_CLI_VERSION}/linux-${BUILDKIT_CLI_VERSION}.tgz | \
  tar -C /usr/local/bin -xzf -
