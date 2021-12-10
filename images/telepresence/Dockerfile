# In order to run telepresence in our concourse CI, we need to make sure
# that iptables is v1.6.1. For some reason latest iptables does not work
# from a garden container (erorrs with Operation not permitted)
FROM ubuntu:bionic

RUN  apt-get update \
  && apt-get install --yes \
       --no-install-recommends \
       apt-transport-https \
       ca-certificates \
       curl \
       git \
       wget \
       jq \
       software-properties-common \
       lsb-release \
       unzip \
       vim \
       gnupg2 \
       sshfs \
       conntrack \
       iptables \
       sudo \
       build-essential \
  && rm -rf /var/lib/apt/lists/*

# Golang
RUN cd /tmp && \
    wget https://dl.google.com/go/go1.17.linux-amd64.tar.gz && \
    tar -xvf go1.17.linux-amd64.tar.gz && \
    mv go /usr/local

ENV GOROOT=/usr/local/go
ENV GOPATH=$HOME/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# telepresence
RUN curl -s https://packagecloud.io/install/repositories/datawireio/telepresence/script.deb.sh | bash
RUN apt-get install -y --no-install-recommends telepresence

# kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl

# ginkgo
RUN go get -u github.com/onsi/ginkgo/ginkgo github.com/onsi/gomega/...

# Gcloud cli
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl -sL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
  apt-get update && \
  apt-get -y install google-cloud-sdk
