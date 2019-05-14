FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install --yes \
      apt-transport-https \
      build-essential \
      ca-certificates \
      curl \
      git \
      gnupg2 \
      jq \
      lsb-release \
      wget \
      zlib1g-dev \
      libssl-dev \
      libreadline-dev \
      software-properties-common

# Add repos (Docker & Ruby)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get update

# Docker
RUN  apt-get install --yes docker-ce=17.09.1~ce-0~ubuntu

# Ruby
RUN apt-get install --yes ruby2.4 && \
    echo "gem: --no-rdoc --no-ri" > ~/.gemrc && \
    gem install bundler && \
    bundle config --global silence_root_warning true

# Golang
ENV GOLANG_VERSION="1.12.5" GOROOT="/goroot" GOPATH="/gopath"
RUN mkdir $GOROOT \
    && mkdir $GOPATH \
    && curl https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz| tar xvzf - -C $GOROOT --strip-components=1
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin

# Direnv
RUN go get -u github.com/cpuguy83/go-md2man && \
    git clone https://github.com/direnv/direnv $GOPATH/src/github.com/direnv/direnv && \
    cd $GOPATH/src/github.com/direnv/direnv && \
    make install && \
    echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

