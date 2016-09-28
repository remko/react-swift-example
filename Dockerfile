FROM ubuntu:14.04

RUN apt-get update && apt-get -y install curl git libedit-dev libcurl4-openssl-dev clang libicu52 make
RUN cd /usr/local && \
	curl -O https://swift.org/builds/swift-3.0-release/ubuntu1404/swift-3.0-RELEASE/swift-3.0-RELEASE-ubuntu14.04.tar.gz && \
	tar xzf swift-3.0-RELEASE-ubuntu14.04.tar.gz --strip-components=2
RUN (curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash) && \
	export NVM_DIR="/root/.nvm" && \
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
	nvm install 4

ADD package.json /opt/src/
RUN export NVM_DIR="/root/.nvm" && \
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
	cd /opt/src && npm install

ADD Package.swift /opt/src/
RUN cd /opt/src && swift package fetch

ADD . /opt/src
RUN export NVM_DIR="/root/.nvm" && \
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
	cd /opt/src && make

WORKDIR "/opt/src"
EXPOSE 8080
CMD ["./.build/debug/App", "serve"]
