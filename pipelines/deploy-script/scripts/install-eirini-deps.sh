#!/bin/bash

set -euox pipefail
IFS=$'\n\t'

main(){
  install_os_deps
  install_vbox
  install_docker
  install_bosh
  install_cf_cli
  install_kubectl
  install_minikube
  install_ruby
  install_go
  set_env_vars
  echo "Installation of eirini dependencies done. You can now start to setup the Eirini environment."
}

install_os_deps(){
  echo Installing OS dependencies
  apt-get update && apt-get upgrade && apt-get dist-upgrade
  apt-get install -y build-essential dkms unzip wget curl git software-properties-common
}

install_vbox(){
  echo Installing VirtualBox
  add-apt-repository "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
  wget --quiet https://www.virtualbox.org/download/oracle_vbox_2016.asc --output-document - | apt-key add -
  apt-get update
  apt-get install virtualbox-5.2 -y
  VBoxManage --version
}

install_docker(){
  echo Installing Docker
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

  apt-get update
  apt-cache policy docker-ce
  apt-get install --yes docker-ce
}

install_bosh(){
  echo Installing BOSH
  wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-3.0.1-linux-amd64 --output-document /usr/local/bin/bosh && chmod +x /usr/local/bin/bosh
  bosh --version
}

install_cf_cli(){
  echo Installing the cf command line tool
  wget --quiet --output-document - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
  echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
  apt-get update
  apt-get install cf-cli -y
  cf --version
}

install_kubectl(){
  echo Installing kubectl
  apt-get update && apt-get install --yes apt-transport-https
  curl --silent https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  touch /etc/apt/sources.list.d/kubernetes.list
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
  apt-get update
  apt-get install --yes kubectl
}

install_minikube(){
  echo Installing minikube
  curl --location --output minikube https://storage.googleapis.com/minikube/releases/v0.28.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
}

install_ruby(){
  echo Installing ruby
  apt install ruby -y
  gem install bundle
}

install_go(){
  echo Installing go
  wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.10.3.linux-amd64.tar.gz
  echo "export PATH=\$PATH:/usr/local/go/bin" >> "$HOME"/.profile
}

set_env_vars() {
  echo 'Adding environment variables to ~/.bash_profile'
  cat > ~/.bash_profile << EOF
export EIRINI_LITE=$HOME/workspace/eirini-lite
export PATH=$PATH:/usr/local/go/bin
EOF

  # shellcheck source=/dev/null
  source ~/.bash_profile
  mkdir -p "$EIRINI_LITE"
}

main
