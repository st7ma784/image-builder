
# Beaker Image Builder

Beaker Image Builder is a GitHub Action that builds Beaker images.

## Authentication

A Beaker user token is required to authenticate with Beaker and create images.
The user token is provided to the image builder through a repository secret.

In your repository, go to `Settings > Secrets` and select `New secret`. 
Set the secret name to `BEAKER_TOKEN` and the value to your user token,
which can be found on your [Beaker user page](https://beaker.org/user).