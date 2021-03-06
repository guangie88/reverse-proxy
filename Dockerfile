ARG NGINX_IMAGE_TAG
FROM nginxinc/nginx-unprivileged:${NGINX_IMAGE_TAG}

ARG TERA_CLI_VERSION=0.1.0

# Some default env vars that reverse proxies 8080 -> 9090
# User should be overriding this to make sense
ENV LISTENING_PORT 8080
ENV SERVER_NAME localhost
ENV USE_GZIP off

ENV LOCATION "/"
ENV PROXY_PASS_URL http://localhost:9090/

# Good presets, setting the env var to empty string will remove the setting of header for that field
ENV PROXY_SET_HEADER_REFERER "\$http_referer"
ENV PROXY_SET_HEADER_X_FORWARDED_FOR "\$remote_addr"
ENV PROXY_SET_HEADER_X_FORWARDED_PROTO "\$scheme"

# Set to false to just use the pre-applied default.conf
# Useful for environment that doesn't easily allow read-write volume at runtime
ENV APPLY_TEMPLATE true

# To make things better for the user 1001, we shall create a designated HOME dir
# https://github.com/nginxinc/docker-nginx-unprivileged/blob/master/stable/alpine/Dockerfile#L153
USER root
RUN set -euo pipefail && \
    mkdir -p /home/1001; \
    chown 1001:1001 /home/1001; \
    :
# We need to override the existing nginx.conf so that it allows us to inject new
# NGINX conf as a user
COPY ./nginx.conf /etc/nginx/
USER 1001

ENV HOME /home/1001
WORKDIR ${HOME}
ENV NGINX_CONF_DIR=${HOME}/nginx/conf.d
ENV NGINX_CONF_TMPL_DIR=${HOME}/nginx/conf.tmpl.d

# There is no choice but to use /tmp because the docker image doesn't have a
# home directory to write into
RUN set -euo pipefail && \
    mkdir -p ${NGINX_CONF_DIR}; \
    mkdir -p .bin/; \
    cd .bin/; \
    wget https://github.com/guangie88/tera-cli/releases/download/v${TERA_CLI_VERSION}/tera_linux_amd64; \
    mv tera_linux_amd64 tera; \
    chmod +x tera; \
    :

ENV PATH=${PATH}:${HOME}/.bin

COPY ./default.conf.tmpl ${NGINX_CONF_TMPL_DIR}/
COPY ./run.sh ${HOME}/
RUN tera -f ${NGINX_CONF_TMPL_DIR}/default.conf.tmpl --env > ${NGINX_CONF_DIR}/default.conf

CMD ["./run.sh"]
