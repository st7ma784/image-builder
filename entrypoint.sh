#!/bin/bash

beaker config set user_token "$INPUT_BEAKERTOKEN"
[[ -n "$INPUT_BEAKERWORKSPACE" ]] && beaker config set default_workspace "$INPUT_BEAKERWORKSPACE"

TAG="docker.pkg.github.com/$GITHUB_REPOSITORY/beaker-image-build-cache"

# Pull cached Docker image.
if [[ -n "$INPUT_GITHUB_TOKEN" ]] then
    # Login to GitHub Package registry.
    echo $INPUT_GITHUB_TOKEN | docker login docker.pkg.github.com -u $GITHUB_ACTOR --password-stdin
    # Pull existing Docker image from cache.
    docker pull docker.pkg.github.com/$GITHUB_REPOSITORY/beaker-image-build-cache || true
fi

docker build . --file "$INPUT_DOCKERFILE" --tag "$TAG" --cache-from="$TAG"

# Push Docker image to cache.
if [[ -n "$INPUT_GITHUB_TOKEN" ]] then
    docker push $TAG
fi

IMAGE=$(beaker image create -q $TAG)

[[ -n "$INPUT_IMAGENAME" ]] && beaker image rename $IMAGE $INPUT_IMAGENAME

echo "set-output name=imageID::$IMAGE"
