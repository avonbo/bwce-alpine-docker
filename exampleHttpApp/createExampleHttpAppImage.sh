#!/bin/bash

if [ -z "$2"  ]; then
	tag=${PWD##*/}:latest
	
else
	tag=$2
fi
tag="$(tr [A-Z] [a-z] <<< "$tag")"
echo "Tag is set to $tag"

earUrl=https://github.com/TIBCOSoftware/bwce-docker/raw/master/examples/HTTP/docker.http.application_1.0.0.ear
curl -LOk -o docker.http.application_1.0.0.ear $earUrl

docker build -t $tag  .