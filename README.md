# cryptoluks

Cryptoluks the easy way.

This repository is meant to help anyone create an encrypted file using Linux native tools.

Tools used:
- cryptsetup
- docker

## docker on a *macOS* (_or linux_) host

### Requirements

- [brew install](https://docs.brew.sh/Installation)
- `brew tap caskroom/cask`

```
brew install coreutils
brew cask install docker
```

### running it

```
./bin/build.sh
./bin/run.sh

./bin/cryptoluks.sh
```

## running the `bin/cryptoluks.sh` directly on the Linux host

```
sudo apt-get -y install \
  cryptsetup exfat-fuse exfat-utils sudo
```

### running it

```
./bin/cryptoluks.sh
```

## Credit

Thanks to:
- [gw0/docker-alpine-kernel-modules](https://github.com/gw0/docker-alpine-kernel-modules.git) for kernel compilation steps.
