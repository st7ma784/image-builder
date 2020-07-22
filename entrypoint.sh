#!/bin/bash

beaker config set user_token "$INPUT_BEAKERTOKEN"
[[ ! -z "$INPUT_BEAKERWORKSPACE" ]] && beaker config set default_workspace "$INPUT_BEAKERWORKSPACE"

TAG="beaker-image-builder"
docker build . --file "$INPUT_DOCKERFILE" --tag $TAG

beaker image create $TAG
