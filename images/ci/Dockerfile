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
  && rm -rf /var/lib/apt/lists/*

# CF CLI
RUN curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=6.49.0&source=github-rel" | tar -zx \
  && mv cf /usr/local/bin

# ginkgo && shfmt
RUN go get -u github.com/onsi/ginkgo/ginkgo github.com/onsi/gomega/... mvdan.cc/sh/cmd/shfmt

# goml
RUN wget --quiet --output-document /usr/bin/goml https://github.com/JulzDiverse/goml/releases/download/v0.7.0/goml-linux-amd64 && chmod +x /usr/bin/goml

