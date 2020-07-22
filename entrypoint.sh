#!/bin/bash

beaker config set user_token "$INPUT_BEAKERTOKEN"
[[ -n "$INPUT_BEAKERWORKSPACE" ]] && beaker config set default_workspace "$INPUT_BEAKERWORKSPACE"

TAG="beaker-image-builder"
docker build . --file "$INPUT_DOCKERFILE" --tag $TAG

IMAGE=$(beaker image create $TAG)

[[ -n "$INPUT_IMAGENAME" ]] && beaker image rename $INPUT_IMAGENAME

echo "set-output name=imageID::$IMAGE"
