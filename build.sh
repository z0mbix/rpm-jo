#!/usr/bin/env bash

set -e

version="$1"
iteration=1
git_user=$(git config --get-all user.name)
git_email=$(git config --get-all user.email)
maintainer="$git_user <$git_email>"

if [[ -z $version ]]; then
  echo 'Please let me know the version as my argument'
  exit 1
fi

if [[ -n $2 ]]; then
  iteration="$2"
fi

if [[ ! -f jo-${version}.tar.gz ]]; then
  curl \
    -L https://github.com/jpmens/jo/releases/download/v${version}/jo-${version}.tar.gz \
    -o jo-${version}.tar.gz
fi

tar xzf jo-${version}.tar.gz
cd jo-${version}
./configure --prefix=/usr
make

rm -rf /tmp/jo-${version}
mkdir /tmp/jo-${version}
make install DESTDIR=/tmp/jo-${version}

fpm \
  -C /tmp/jo-${version} \
  -s dir \
  -t rpm \
  --name jo \
  --version "$version" \
  --iteration $iteration \
  --maintainer "$maintainer" \
  --description "jq is a a small utility to create JSON objects" \
  --url 'http://jpmens.net/2016/03/05/a-shell-command-to-create-json-jo/' \
  --package .. \
  usr

cd ..
rm -rf jo-${version} /tmp/jo-${version}

