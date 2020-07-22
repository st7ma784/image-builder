
# Beaker Image Builder

The Beaker Image Builder is a GitHub Action that builds Beaker images
automatically in the cloud.

Building images on your own machine can be frustratingly slow, especially over a home internet connection.
Faster internet connections in the cloud make image building much faster.
With the Beaker Image Builder, the basic workflow is:

1. Push changes to GitHub.
1. Wait for the image to build.
1. Start Beaker experiments with the new image.

## Configuration

### Beaker User Token

A Beaker user token is required to authenticate with Beaker and create images.
The user token is provided to the image builder through a [repository secret](https://docs.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets).
To configure it:

1. Navigate to the main page of the repository.
1. Click **Settings**.
1. In the left sidebar, click **Secrets**.
1. Click **Add new secret**.
1. Set the name of the secret to `BEAKER_TOKEN`.
1. Set the value of the secret to your Beaker user token, which can be found on the [Beaker user page](https://beaker.org/user).
1. Click **Add secret**.

![Setting Beaker token secret](/images/beaker-token-secret.png)

## Image Builder Action

To get started, copy the file below into `.github/workflows/beaker.yml` and commit it.

This example will build a Beaker image for every commit to the master branch.
For additional configuration options, see **Inputs** below.

```yaml
name: Beaker Image Builder
on:
  push:
    # Run on every commit to the master branch.
    branches: [ master ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    # Check out the repository so that the Beaker Image Builder can access it.
    - uses: actions/checkout@v2
    - name: Beaker Image Builder
      uses: beaker/image-builder@master
      with:
        beaker_token: ${{ secrets.BEAKER_TOKEN }}
        github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

### `beaker_token`

**Required**. Beaker user token. This should be stored as a repository secret using the instructions above.
The user token grants full access to a Beaker account so it must not be stored in the repository.

### `beaker_workspace`

Beaker workspace for the built image. If omitted, the default workspace is used.

### `beaker_image_name`

Name for the built image.
If omitted, the image will be named using the repository name and the SHA hash of the latest commit, e.g. `repo-1234abc`.

### `dockerfile`

Path to the Dockerfile. Defaults to `Dockerfile` at the root of the repository.

### `github_token`

The GitHub token is used to authenticate with the GitHub Package Registry for caching Docker builds. If omitted, caching will be disabled.

## Usage

Once configured, Beaker images will be built for each commit.
To check the status of an image build, go to the **Actions** tab
or hover on the status indicator of a commit.

![Action status page](/images/actions-status.png)

Once an image is created, it will be visible on the [Beaker image search page](https://beaker.org/images?sort=committed:descending&creator=me)
with a link back to the source commit.