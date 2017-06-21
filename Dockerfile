FROM centos:7
MAINTAINER matthewcmead <matthewcmead@gmail.com>

RUN \
    rpm -Uvh https://rpm.nodesource.com/pub_4.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm \
&&  yum groups mark install "Development Tools" \
&&  yum groups mark convert "Development Tools" \
&&  yum groupinstall -y 'Development Tools' \
&&  yum install -y \
      curl \
      unzip \
      python \
      cairo-devel \
      protobuf-devel \
      xorg-x11-server-Xvfb \
      which \
      nodejs \
      centos-release-scl \
      centos-release-scl-rh \
      scl-utils \
      mesa-dri-drivers \
&&  yum install -y \
      devtoolset-4-gcc* \
&&  yum clean all

RUN \
    scl enable devtoolset-4 'which g++' \
&&  cd /tmp \
&&  curl -O https://cmake.org/files/v3.8/cmake-3.8.2.tar.gz \
&&  tar zxf cmake-3.8.2.tar.gz \
&&  cd cmake-3.8.2 \
&&  scl enable devtoolset-4 './bootstrap' \
&&  scl enable devtoolset-4 'gmake' \
&&  scl enable devtoolset-4 'gmake install' \
&&  cd .. \
&&  rm -rf cmake-3.8.2 cmake-3.8.2.tar.gz

RUN \
    yum install -y \
      libcurl-devel \
&&  yum clean all

RUN mkdir -p /usr/src/app
COPY / /usr/src/app

RUN \
    cd /usr/src/app \
&&  scl enable devtoolset-4 'npm install --production' \
&&  cd node_modules/\@mapbox/mapbox-gl-native \
&&  scl enable devtoolset-4 'npm install' \
&&  scl enable devtoolset-4 'make BUILDTYPE=Release node' \
&&  rm -rf node_modules

RUN \
    cd /usr/lib64 && ln -s libcurl.so.4 libcurl-gnutls.so.4

VOLUME /data
WORKDIR /data

ENV NODE_ENV="production"

EXPOSE 80
ENTRYPOINT ["/usr/src/app/run.sh"]

