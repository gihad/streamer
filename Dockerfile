FROM nginx:stable-alpine

# Install ffmpeg and configure nginx
RUN apk add --update nginx ffmpeg && rm -rf /var/cache/apk/* && mkdir /tmp/stream
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# =================================================================================
# Fix up permissions for OpenShift (non-root Docker user)
# ref: https://torstenwalter.de/openshift/nginx/2017/08/04/nginx-on-openshift.html
# - Make sure nginx can read and write it's working directories.
# - The container dynamically configures nginx on startup
# - The application artifacts live in /tmp
# ---------------------------------------------------------------------------------
RUN chmod g+rw /var/run \
               /var/log/nginx \
               /etc/nginx/nginx.conf \
               /tmp \ 
               /tmp/stream
# =================================================================================

COPY ./startup.sh /
COPY ./create_ffmpeg_cmd.sh /
RUN ["chmod", "+x", "/startup.sh"]
RUN ["chmod", "+x", "/create_ffmpeg_cmd.sh"]

CMD ["/startup.sh"]
