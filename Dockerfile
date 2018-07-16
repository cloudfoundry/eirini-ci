FROM golang:1.10.2

ENV PATH="$GOPATH/bin:${PATH}"

RUN apt-get update && \
    apt-get install -y \
      git-all \
      wget \
      curl \
      ruby

RUN echo "gem: --no-rdoc --no-ri" > ~/.gemrc

RUN gem install bundler

RUN wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64.zip && \
    unzip spiff_linux_amd64.zip && mv spiff /usr/local/bin/ && rm spiff_linux_amd64.zip

# EirniFS
RUN mkdir /eirini
COPY cubefs.tar /eirini/eirinifs.tar

# bosh2
RUN wget --quiet https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-3.0.1-linux-amd64 -O /usr/bin/bosh && chmod +x /usr/bin/bosh

# kubectl
RUN wget --quiet https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -O /usr/bin/kubectl && chmod +x /usr/bin/kubectl

# ginkgo
RUN go get github.com/onsi/ginkgo/ginkgo
RUN go get github.com/onsi/gomega/...

# helm
RUN wget --quiet https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz && tar xfz helm-v2.9.1-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/ && chmod +x /usr/bin/helm

# goml
RUN wget --quiet -O /usr/bin/goml https://github.com/JulzDiverse/goml/releases/download/v0.4.0/goml-linux-amd64 && chmod +x /usr/bin/goml
