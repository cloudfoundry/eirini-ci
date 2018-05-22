FROM golang:1.10.2

ENV PATH="$GOPATH/bin:${PATH}"

RUN apt-get update && \
    apt-get install -y \
      git-all \
      wget \
      curl

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
