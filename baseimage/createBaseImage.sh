#!/bin/bash
# Copyright (c) 2016, TIBCO Software Inc. All rights reserved.
# You may not use this file except in compliance with the license 
# terms contained in the TIBCO License.md file provided with this file.


if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: ./createDockerImage.sh <path/to/bwce_cf.zip> <Tag>"
    echo "Location of bwce_cf.zip"
    echo "Version Eg: v2.0.0"
    exit 1
fi


#set tagname
if [ -z "$2"  ]; then
	tag="alpinebwcebase:latest"
else
	tag="alpinebwcebase:"$2
fi
echo "Tag is set to $tag"


#copy bwce_cf.zip, the bwce runtime
zipLocation=$1
mkdir -p bwce-runtime && cp -i $zipLocation "$_"

#Download the original token resolver
tibcoTokenResolverURL=https://raw.githubusercontent.com/TIBCOSoftware/bwce-docker/master/java-code/ProfileTokenResolver.java
curl -o java-code/ProfileTokenResolver.java $tibcoTokenResolverURL


docker build -f Dockerfile -t $tag .

rm -rf bwce-runtime
