FROM docker

RUN apk --no-cache add wget bash

# Install Beaker CLI.
RUN wget https://github.com/allenai/beaker/releases/download/v20200716/beaker_linux.tar.gz \
    && tar -xvzf beaker_linux.tar.gz \
    && mv beaker /usr/local/bin

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]