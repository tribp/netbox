FROM lscr.io/linuxserver/netbox:arm64v8-3.2.5
RUN apk update
# adding missing dependencies to run Pillow library in python on alpine
RUN apk add tiff-dev jpeg-dev openjpeg-dev zlib-dev freetype-dev lcms2-dev \
    libwebp-dev tcl-dev tk-dev harfbuzz-dev fribidi-dev libimagequant-dev \
    libxcb-dev libpng-dev
RUN mkdir -p /var/lib/postgresql/data
RUN chmod 777 /var/lib/postgresql/data
ENTRYPOINT [ "/init" ]