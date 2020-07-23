#!/bin/bash

set -e

beaker config set user_token "$INPUT_BEAKER_TOKEN"
[[ -n "$INPUT_BEAKER_WORKSPACE" ]] && beaker config set default_workspace "$INPUT_BEAKER_WORKSPACE"

# Docker repository names must be lowercase.
TAG=$(echo "docker.pkg.github.com/$GITHUB_REPOSITORY/beaker-image-build-cache" | tr '[:upper:]' '[:lower:]')

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

DESC="https://github.com/$GITHUB_REPOSITORY/tree/$GITHUB_SHA"

DEFAULT_NAME=$(echo "$GITHUB_REPOSITORY" | awk -F / '{print $2}')-${GITHUB_SHA::7}
NAME="${INPUT_BEAKER_IMAGE_NAME:-$DEFAULT_NAME}"

beaker image create --desc $DESC --name $NAME $TAG
