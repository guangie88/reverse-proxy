# Reverse Proxy

Pure reverse proxy that allows use of environment variables for configuration.

This uses
[`Unprivileged NGINX`](https://github.com/nginxinc/docker-nginx-unprivileged) in
order to make it more usable in various deployments.

Note that this Docker image changes the base image such that it has a default
`HOME` directory. The default include glob `/etc/nginx/conf.d/*.conf` has been
removed, and is instead replaced with glob pattern
`${HOME}/nginx/conf.d/*.conf` for including new `nginx` conf files.

## Environment variables to override

By default `APPLY_TEMPLATE` is set to `"true"` and the start-up script will
perform a runtime interpolation of the configuration before running the NGINX
server.

If you are not interested in doing so, or prefer to just volume mount in the
`default.conf` file directly, set `APPLY_TEMPLATE` to `"false"` to prevent the
runtime interpolation.

The rest are applicable when `APPLY_TEMPLATE` is set to `"true"`:

- `LISTENING_PORT`
  - Listening address of the reverse proxy, e.g. `8080`
- `SERVER_NAME`
  - Server name label in the Nginx `server` block, e.g. `localhost`
- `LOCATION`
  - Location to serve the proxy-pass, defaults to `/` to serve the reverse proxy
    at root path.
- `PROXY_PASS_URL`
  - URL to proxy pass into, e.g. `http://localhost:9090/`
- `PROXY_SET_HEADER_HOST`
  - Value to set into the `Host` header. Not setting it defaults it to
    `proxy_set_header Host $proxy_host`, which is usually preferred.
- `PROXY_SET_HEADER_REFERER`
  - Value to set into the `Referer` header.
    Defaults to `"proxy_set_header Referer $http_referer;"`
- `PROXY_SET_HEADER_X_FORWARDED_FOR`
  - Value to set into the `X-Forwarded-For` header.
    Defaults to `"proxy_set_header X-Forwarded-For $remote_addr;"`
- `PROXY_SET_HEADER_X_FORWARDED_PROTO`
  - Value to set into the `X-Forwarded-Proto` header.
    Defaults to `"proxy_set_header X-Forwarded-Proto $scheme;"`

Again, the start-up script is set to run
`${HOME}/nginx/conf.d/default.conf.tmpl > ${HOME}/nginx/conf.d/default.conf`
unless `APPLY_TEMPLATE` is set to `"false"`.
