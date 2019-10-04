FROM ubuntu:bionic

RUN apt-get update \
  && apt-get install --no-install-recommends -y software-properties-common git libdevmapper1.02.1 jq \
  && add-apt-repository -y ppa:projectatomic/ppa \
  && apt-get update \
  && apt-get install --no-install-recommends -y buildah \
  && rm -rf /var/lib/apt/lists/*
