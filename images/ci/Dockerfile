FROM golang:stretch

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
       vim \
  && rm -rf /var/lib/apt/lists/*

# CF CLI
RUN curl --fail --silent --show-error --location https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -\
  && echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list \
  && apt-get update \
  && apt-get install -y cf-cli \
  && rm -rf /var/lib/apt/lists/*

# Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && apt-key fingerprint 0EBFCD88 \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
  && apt-get update \
  && apt-get install -y docker-ce=17.09.1~ce-0~debian \
  && rm -rf /var/lib/apt/lists/*

# ginkgo && shfmt
RUN go get -u github.com/onsi/ginkgo/ginkgo github.com/onsi/gomega/... mvdan.cc/sh/cmd/shfmt

# goml
RUN wget --quiet --output-document /usr/bin/goml https://github.com/JulzDiverse/goml/releases/download/v0.4.0/goml-linux-amd64 && chmod +x /usr/bin/goml

