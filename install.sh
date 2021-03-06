#!/bin/bash

set -e
set -x

# gcc libffi-dev
sudo apt-get install python3-pip virtualenv screen unzip -y

if [ -z "$VIRTUAL_ENV" ]; then
    virtualenv -p python3 D4GENV
    echo export D4G_HOME=$(pwd) >> ./D4GENV/bin/activate
    . ./D4GENV/bin/activate
fi

python3 -m pip install -r requirement.txt

if [ ! -d d4-core ]; then
  git clone https://github.com/D4-project/d4-core.git
  pushd d4-core
  pushd client
  git submodule init
  git submodule update
  make
  sleep 5
  popd
  popd
fi
if [ ! -d d4-goclient ]; then
  git clone https://github.com/D4-project/d4-goclient.git
fi

pushd configs
  cp server.conf.sample server.conf
popd

mkdir logs

pushd d4-goclient
gox -output="../exe_goclient/d4-goclient_{{.OS}}_{{.Arch}}"
sleep 5
popd

pushd exe_goclient
find . -type f -exec sha256sum {} \; > ../sha256sum.txt
popd

# REDIS #
test ! -d redis/ && git clone https://github.com/antirez/redis.git
pushd redis/
git checkout 5.0
make
popd

./update_web.sh
