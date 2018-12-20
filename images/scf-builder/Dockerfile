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
      zlib1g-dev \
      libssl-dev \
      libreadline-dev \
      software-properties-common

# bosh2
RUN curl --fail --silent --show-error --location --output /usr/bin/bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-3.0.1-linux-amd64 && chmod +x /usr/bin/bosh

# Direnv
RUN go get -u github.com/mvdan/sh/cmd/shfmt && \
    git clone https://github.com/direnv/direnv $GOPATH/src/github.com/direnv/direnv && \
    cd $GOPATH/src/github.com/direnv/direnv && \
    make install && \
    echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

# Docker
RUN  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && apt-key fingerprint 0EBFCD88 \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  && apt-get update \
  && apt-get install -y docker-ce

# Fissile
ENV FISSILE_SHA1="311b07d9462f6fc091f126ec28abe4db6cf8ea32"
RUN git clone https://github.com/SUSE/fissile $GOPATH/src/github.com/SUSE/fissile \
&& cd $GOPATH/src/github.com/SUSE/fissile \
&& git reset --hard ${FISSILE_SHA1} \
&& git pull origin ${FISSILE_SHA1} \
&& make tools \
&& make build \
&& mv $GOPATH/src/github.com/SUSE/fissile/build/linux-amd64/fissile /usr/local/bin/fissile

# Golang
ENV GOLANG_VERSION="1.10.1" GOROOT="/goroot" GOPATH="/gopath"
RUN mkdir /goroot \
&& mkdir /gopath \
&& curl https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin

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

# Stampy
RUN go get -d github.com/SUSE/stampy \
&& cd $GOPATH/src/github.com/SUSE/stampy \
&& make tools \
&& make all \
&& mv $GOPATH/src/github.com/SUSE/stampy/build/linux-amd64/stampy /usr/local/bin/stampy

