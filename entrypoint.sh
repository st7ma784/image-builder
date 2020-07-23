#!/bin/bash

set -e

beaker config set user_token "$INPUT_BEAKER_TOKEN"
[[ -n "$INPUT_BEAKER_WORKSPACE" ]] && beaker config set default_workspace "$INPUT_BEAKER_WORKSPACE"

# The last section of the name must be globally unique, so add a hash of the repo name.
TAG="docker.pkg.github.com/$GITHUB_REPOSITORY/beaker-image-build-cache-$(echo $GITHUB_REPOSITORY | md5sum | cut -d' ' -f1)"
# Docker repository names must be lowercase.
TAG=$(echo $TAG | tr '[:upper:]' '[:lower:]')

# Pull cached Docker image.
if [[ -n "$INPUT_GITHUB_TOKEN" ]]
then
    # Login to GitHub Package registry.
    echo $INPUT_GITHUB_TOKEN | docker login docker.pkg.github.com -u $GITHUB_ACTOR --password-stdin
    # Pull existing Docker image from cache.
    docker pull docker.pkg.github.com/$GITHUB_REPOSITORY/beaker-image-build-cache || true
fi

docker build . --file "$INPUT_DOCKERFILE" --tag "$TAG" --cache-from="$TAG"

DESC="https://github.com/$GITHUB_REPOSITORY/tree/$GITHUB_SHA"

DEFAULT_NAME=$(echo "$GITHUB_REPOSITORY" | awk -F / '{print $2}')-${GITHUB_SHA::7}
NAME="${INPUT_BEAKER_IMAGE_NAME:-$DEFAULT_NAME}"

beaker image create --desc $DESC --name $NAME $TAG

# Push Docker image to cache.
if [[ -n "$INPUT_GITHUB_TOKEN" ]]
then
    docker push $TAG
fi
