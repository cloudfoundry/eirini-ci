FROM google/cloud-sdk

RUN apt-get update && \
    apt-get install --yes \
      jq \
      unzip \
      wget \
      vim \
  && rm -rf /var/lib/apt/lists/*

# helm
RUN wget --quiet https://storage.googleapis.com/kubernetes-helm/helm-v2.14.1-linux-amd64.tar.gz && tar xfz helm-v2.14.1-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/ && chmod +x /usr/bin/helm

RUN wget https://releases.hashicorp.com/terraform/0.12.9/terraform_0.12.9_linux_amd64.zip \
      && unzip terraform_0.12.9_linux_amd64.zip \
      && mv terraform /usr/local/bin/ \
      && rm terraform_0.12.9_linux_amd64.zip
