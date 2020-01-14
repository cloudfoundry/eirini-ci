FROM cloudfoundry/cflinuxfs3

# Install Golang
ENV GOLANG_VERSION 1.13.6
RUN bash -o pipefail -c "curl -sSL https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz | tar -v -C /usr/local -xz"
ENV GOROOT /usr/local/go
ENV PATH $PATH:$GOROOT/bin
WORKDIR /eirinistaging

ENV GOPATH=/root
ENV PATH=$GOPATH/bin:$PATH

RUN rm -rf /tmp/*
RUN go get github.com/onsi/ginkgo/ginkgo

CMD ginkgo -r
