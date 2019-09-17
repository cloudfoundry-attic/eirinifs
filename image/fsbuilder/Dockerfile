FROM golang:latest

RUN apt-get update && \
    apt-get install --yes \
      apt-transport-https \
      lsb-release \
      software-properties-common

# Docker
# Due to issue with the docker version used in this image, it needs to be donwgraded until this issue is resolved (https://github.com/docker/for-linux/issues/219#issuecomment-375199143)
RUN  curl --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && apt-key fingerprint 0EBFCD88 \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
  && apt-get update \
  && apt-get install -y docker-ce=17.09.1~ce-0~debian

