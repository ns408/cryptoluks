FROM ubuntu:18.04
COPY ./bin/simpleluks.sh /app

RUN apt-get update -y && sudo apt-get install -y \
  cryptsetup \
  sudo
