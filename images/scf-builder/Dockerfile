FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install --yes \
      apt-transport-https \
      bash \
      build-essential \
      ca-certificates \
      curl \
      git \
      gnupg2 \
      jq \
      lsb-release \
      zlib1g \
      wget \
      zlib1g-dev \
      libssl-dev \
      libreadline-dev \
      software-properties-common

# Golang
ENV GOLANG_VERSION="1.10.8" GOROOT="/goroot" GOPATH="/gopath"
RUN mkdir /goroot \
&& mkdir /gopath \
&& curl https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin

# Direnv
RUN go get -u github.com/mvdan/sh/cmd/shfmt && \
    go get -u github.com/cpuguy83/go-md2man && \
    git clone https://github.com/direnv/direnv $GOPATH/src/github.com/direnv/direnv && \
    cd $GOPATH/src/github.com/direnv/direnv && \
    make install && \
    echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

# Docker
RUN  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && apt-key fingerprint 0EBFCD88 \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  && apt-get update \
  && apt-get install -y docker-ce=17.09.1~ce-0~ubuntu

# Pip
RUN apt-get install -y python \
&& curl -O https://bootstrap.pypa.io/get-pip.py \
&& python get-pip.py --user \
&& rm -rf get-pip.py

# Ruby
RUN apt-get install --yes software-properties-common && \
    apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install --yes ruby2.4 && \
    echo "gem: --no-rdoc --no-ri" > ~/.gemrc && \
    gem install bundler && \
    bundle config --global silence_root_warning true

