FROM alpine:3.7

# Install nginx and ffmpeg
RUN apk add --update nginx ffmpeg && rm -rf /var/cache/apk/* && mkdir /tmp/stream
COPY nginx/nginx.conf /etc/nginx/nginx.conf

COPY ./startup.sh /
COPY ./create_ffmpeg_cmd.sh /
RUN ["chmod", "+x", "/startup.sh"]
RUN ["chmod", "+x", "/create_ffmpeg_cmd.sh"]

CMD ["/startup.sh"]
