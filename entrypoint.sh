#!/bin/bash

set -e

beaker config set user_token "$INPUT_BEAKER_TOKEN"
[[ -n "$INPUT_BEAKER_WORKSPACE" ]] && beaker config set default_workspace "$INPUT_BEAKER_WORKSPACE"

# The last section of the name must be globally unique, so add a hash of the repo name.
TAG="$DOCKERFILE"
#"docker.pkg.github.com/$GITHUB_REPOSITORY/beaker-image-build-cache-$(echo $GITHUB_REPOSITORY | md5sum | cut -d' ' -f1)"
# Docker repository names must be lowercase.

TAG=$(echo $TAG | tr '[:upper:]' '[:lower:]')

# Pull cached Docker image.
if [[ -n "$INPUT_GITHUB_TOKEN" ]]
then
    # Login to GitHub Package registry.
    echo $INPUT_GITHUB_TOKEN | docker login docker.pkg.github.com -u $GITHUB_ACTOR --password-stdin
    # Pull existing Docker image from cache.
    docker pull $TAG || true
fi

DESC="https://github.com/$GITHUB_REPOSITORY/tree/$GITHUB_SHA"

DEFAULT_NAME=$(echo "$GITHUB_REPOSITORY" | awk -F / '{print $2}')-${GITHUB_SHA::7}
NAME="${INPUT_BEAKER_IMAGE_NAME:-$DEFAULT_NAME}"

if [[ "$INPUT_BEAKER_IMAGE_NAME_OVERWRITE" = "true" ]]
then
    beaker image rename $NAME "" && echo "Removed name of existing image" || echo "No existing image found"
fi

beaker image create --description $DESC --name $NAME $TAG


if [[ -n "$INPUT_SPEC_FILE" ]]
then
    IMAGE=$NAME IMAGE=$NAME beaker experiment create "$INPUT_SPEC_FILE"
fi


