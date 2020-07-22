#!/bin/bash

beaker config set user_token "$INPUT_BEAKER_TOKEN"
[[ -n "$INPUT_BEAKER_WORKSPACE" ]] && beaker config set default_workspace "$INPUT_BEAKER_WORKSPACE"

TAG="docker.pkg.github.com/$GITHUB_REPOSITORY/beaker-image-build-cache"

# Pull cached Docker image.
if [[ -n "$INPUT_GITHUB_TOKEN" ]]
then
    # Login to GitHub Package registry.
    echo $INPUT_GITHUB_TOKEN | docker login docker.pkg.github.com -u $GITHUB_ACTOR --password-stdin
    # Pull existing Docker image from cache.
    docker pull docker.pkg.github.com/$GITHUB_REPOSITORY/beaker-image-build-cache || true
fi

docker build . --file "$INPUT_DOCKERFILE" --tag "$TAG" --cache-from="$TAG"

# Push Docker image to cache.
if [[ -n "$INPUT_GITHUB_TOKEN" ]]
then
    docker push $TAG
fi

IMAGE=$(beaker image create -q $TAG)

if [[ -n "$INPUT_IMAGE_NAME" ]]
then
    beaker image rename $IMAGE $INPUT_IMAGE_NAME
fi

echo "set-output name=image_id::$IMAGE"
