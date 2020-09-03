FROM golang:latest

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
       yarnpkg \
       apt-transport-https \
       gnupg2 \
       sshfs \
       conntrack \
       iptables \
       sudo \
  && rm -rf /var/lib/apt/lists/*

# telepresence
RUN curl -s https://packagecloud.io/install/repositories/datawireio/telepresence/script.deb.sh | bash
RUN apt-get install -y --no-install-recommends telepresence

# kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl

# CF CLI
RUN curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=6.49.0&source=github-rel" | tar -zx \
  && mv cf /usr/local/bin

# ginkgo && shfmt
RUN go get -u github.com/onsi/ginkgo/ginkgo github.com/onsi/gomega/... mvdan.cc/sh/cmd/shfmt

# goml
RUN wget --quiet --output-document /usr/bin/goml https://github.com/JulzDiverse/goml/releases/download/v0.7.0/goml-linux-amd64 && chmod +x /usr/bin/goml

