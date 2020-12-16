FROM alpine

ARG FFMPEG_VERSION=4.3.1

RUN apk add --no-cache bash bc fontconfig ttf-ubuntu-font-family coreutils

RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz \
    && tar xf ffmpeg-release-amd64-static.tar.xz \
    && mv ffmpeg-${FFMPEG_VERSION}-amd64-static/ffmpeg /usr/bin/ \
    && mv ffmpeg-${FFMPEG_VERSION}-amd64-static/ffprobe /usr/bin/

COPY thumbs.sh /usr/bin/genThumbs

WORKDIR "/home/"

ENTRYPOINT ["/bin/bash", "/usr/bin/genThumbs"]
