FROM docker

RUN apk --no-cache add bash curl wget

# Install Beaker CLI.
RUN curl -s https://api.github.com/repos/allenai/beaker/releases/latest \
        | grep 'browser_download_url.*linux' \
        | cut -d '"' -f 4 \
        | wget -qi - \
    && tar -xvzf beaker_linux.tar.gz -C /usr/local/bin \
    && rm beaker_linux.tar.gz

COPY dockerfiles /dockerfiles
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
