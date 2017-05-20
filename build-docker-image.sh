#!/bin/bash
set -e

mix compile
VERSION=`mix loadmaster.version`

docker run --rm \
  -v `pwd`:/source:ro \
  -v `pwd`/tarballs:/stage/tarballs:rw \
  -e RELEASE_STRIP=true \
  -e MIX_ENV=prod \
  edib/edib-tool:1.6.0

docker build --build-arg VERSION=$VERSION -t dsander/loadmaster:latest .

if [[ "${CI}" == 'true' && -z "${TRAVIS_TAG}" ]]; then
  echo "Not pushing docker image for non-tagged commits"
  exit 0
fi

if [[ "${CI}" == 'true' ]]; then
  docker login -u $DOCKER_USER -p $DOCKER_PASS
  docker tag dsander/loadmaster:latest dsander/loadmaster:$VERSION
  docker push dsander/loadmaster:latest
  docker push dsander/loadmaster:$VERSION
fi
