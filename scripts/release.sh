#!/usr/bin/env bash

# build our image. We kind of rely on $0 to return the correct value here
my_dir="$(dirname "$0")"
"$my_dir/build.sh" $1

# add it as latest
docker tag pinoniq/php7:$1 pinoniq/php7:latest

# push to docker
docker push pinoniq/php7:$1
docker push pinoniq/php7:latest
