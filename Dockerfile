FROM nginx:1.15-alpine

ARG ENVJA_VERSION=0.2.0

# Some default env vars that reverse proxies 80 -> 8080
ENV LISTENING_ADDR 80
ENV SERVER_NAME localhost
ENV PROXY_PASS_URL http://localhost:8080/

# Set to false to just use the pre-applied default.conf
# Useful for environment that doesn't easily allow read-write volume at runtime
ENV APPLY_TEMPLATE true

RUN set -euo pipefail && \
    wget https://github.com/guangie88/envja/releases/download/v${ENVJA_VERSION}/envja_linux_amd64; \
    mv envja_linux_amd64 envja; \
    chmod +x envja; \
    mv envja /usr/local/bin/; \
    :

COPY ./default.conf.tmpl /etc/nginx/conf.d/
RUN envja file /etc/nginx/conf.d/default.conf.tmpl > /etc/nginx/conf.d/default.conf

CMD ["sh", "-c", "if [[ \"${APPLY_TEMPLATE}\" = \"true\" ]]; then envja file /etc/nginx/conf.d/default.conf.tmpl > /etc/nginx/conf.d/default.conf; fi && exec nginx -g \"daemon off;\""]
