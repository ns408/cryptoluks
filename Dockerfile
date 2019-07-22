FROM ubuntu:18.04
COPY ./bin/simpleluks.sh /app

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get install -y \
  cryptsetup \
  sudo
