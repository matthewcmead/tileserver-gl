#!/usr/bin/env bash

docker build -t matthewcmead/tileserver-gl-centos7-big .
docker run -i --rm --entrypoint /bin/bash matthewcmead/tileserver-gl-centos7-big -c "cd /usr/src && tar cf - app" |gzip -c >app.tar.gz
docker build -f Dockerfile_from_app_tar -t matthewcmead/tileserver-gl-centos7 .
