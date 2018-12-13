#!/bin/bash

set -u
set -e

DATE_TAG=$(date +%Y-%m)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp $DIR/test/*.py $DIR/docker/nompi
cp $DIR/*.tar.gz $DIR/docker/nompi
docker build $DIR/docker/nompi \
             -t software/vislab
docker run -t --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v ${DIR}:/output singularityware/docker2singularity:v2.6 --name software-private-vislab-${DATE_TAG} software/vislab

cp $DIR/test/*.py $DIR/docker/comet
cp $DIR/*.tar.gz $DIR/docker/comet
docker build $DIR/docker/comet \
             -t software/comet
docker run -t --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v ${DIR}:/output singularityware/docker2singularity:v2.6 --name software-private-comet-${DATE_TAG} software/comet

cp $DIR/test/*.py $DIR/docker/flux
cp $DIR/*.tar.gz $DIR/docker/flux
docker build $DIR/docker/flux \
             -t software/flux
docker run -t --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v ${DIR}:/output singularityware/docker2singularity:v2.6 --name software-private-flux-${DATE_TAG} software/flux

cp $DIR/test/*.py $DIR/docker/bridges
cp $DIR/*.tar.gz $DIR/docker/bridges
docker build $DIR/docker/bridges \
             -t software/bridges
docker run -t --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v ${DIR}:/output singularityware/docker2singularity:v2.6 --name software-private-bridges-${DATE_TAG} software/bridges

cp $DIR/test/*.py $DIR/docker/stampede2
cp $DIR/*.tar.gz $DIR/docker/stampede2
docker build $DIR/docker/stampede2 \
             -t software/stampede2
docker run -t --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v ${DIR}:/output singularityware/docker2singularity:v2.6 --name software-private-stampede2-${DATE_TAG} software/stampede2
