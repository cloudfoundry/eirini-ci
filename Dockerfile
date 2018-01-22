FROM pivotalservices/bosh2-docker

RUN apt-get update && \
    apt-get install -y \
      wget \
      curl

# kubectl
RUN wget --quiet https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -O /usr/bin/kubectl && chmod +x /usr/bin/kubectl

# minikube
RUN wget --quiet  https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -O /usr/bin/minikube && chmod +x /usr/bin/minikube
