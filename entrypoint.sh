#!/bin/bash

beaker config set user_token $INPUT_BEAKERTOKEN

TAG="beaker-image-builder"
docker build . --file $INPUT_DOCKERFILE --tag $TAG

beaker image create $TAG
