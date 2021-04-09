FROM golangci/golangci-lint:latest

# yq
RUN curl -sLo yq https://github.com/mikefarah/yq/releases/download/v4.6.2/yq_linux_amd64 \
  && install yq /usr/bin/ \
  && rm -f yq
