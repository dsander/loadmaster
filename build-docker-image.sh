#!/bin/bash
set -e

mix compile
VERSION=`mix loadmaster.version`

if [[ "${CI}" == 'true' && -z "${TRAVIS_TAG}" ]]; then
  echo "Not building docker image for non-tagged commits"
  exit 0
fi

docker run --rm \
  -v `pwd`:/source \
  -v `pwd`/tarballs:/stage/tarballs \
  -e RELEASE_STRIP=true \
  edib/edib-tool:1.3.0

docker build --build-arg VERSION=$VERSION -t dsander/loadmaster .

if [[ "${CI}" == 'true' ]]; then
  docker login -u $DOCKER_USER -p $DOCKER_PASS
  docker tag dsander/loadmaster dsander/loadmaster:$VERSION
  docker push dsander/loadmaster
  docker push dsander/loadmaster:$VERSION
fi
