FROM centos:7
MAINTAINER matthewcmead <matthewcmead@gmail.com>

RUN \
    rpm -Uvh https://rpm.nodesource.com/pub_6.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm \
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
      nodejs-6.11.5 \
      centos-release-scl \
      centos-release-scl-rh \
      scl-utils \
      mesa-dri-drivers \
      openssl-devel \
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
COPY /app /usr/src/app

RUN \
    cd /usr/src/app \
&&  scl enable devtoolset-4 'npm install --production' \
&&  cd node_modules/\@mapbox/mapbox-gl-native \
&&  scl enable devtoolset-4 'npm install' \
&&  sed -i.bak "s/-Werror//" CMakeLists.txt \
&&  scl enable devtoolset-4 'make BUILDTYPE=Release node' \
&&  rm -rf node_modules

RUN \
    cd /usr/lib64 && ln -s libcurl.so.4 libcurl-gnutls.so.4

RUN \
    cd /tmp \
&&  git clone https://github.com/klokantech/tileserver-gl-styles \
&&  cd tileserver-gl-styles/styles_modules \
&&  mkdir dark_matter \
&&  echo "https://github.com/openmaptiles/dark-matter-gl-style/releases/download/v1.4/v1.4.zip" >dark_matter/url \
&&  mkdir fiord-color \
&&  echo "https://github.com/openmaptiles/fiord-color-gl-style/releases/download/v1.4/v1.4.zip" >fiord-color/url \
&&  mkdir positron \
&&  echo "https://github.com/openmaptiles/positron-gl-style/releases/download/v1.5/v1.5.zip" >positron/url

RUN \
    yum install -y wget

RUN \
    cd /tmp/tileserver-gl-styles \
&&  head -n -4 publish.js >publish.js.new \
&&  mv -f publish.js.new publish.js \
&&  node publish.js  \
&&  rm -rf /usr/src/app/node_modules/tileserver-gl-styles/styles/* \
&&  mv styles/* /usr/src/app/node_modules/tileserver-gl-styles/styles \
&&  for x in /usr/src/app/node_modules/tileserver-gl-styles/styles/*/style.json; do sed -i.bak 's/"\([^"]*name:[^"]*latin[^"]*\)"/"{name_en}"/g' $x; done
#&&  for x in /usr/src/app/node_modules/tileserver-gl-styles/styles/*/style.json; do sed -i.bak 's/"\([^"]*name:[^"]*latin[^"]*\)"/"{name_en}\\n\1"/g' $x; done



VOLUME /data
WORKDIR /data

ENV NODE_ENV="production"

EXPOSE 80
ENTRYPOINT ["/usr/src/app/run.sh"]

