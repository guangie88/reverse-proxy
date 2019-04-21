# Reverse Proxy

Pure reverse proxy that allows use of environment variables for configuration.

This uses
[`Unprivileged NGINX`](https://github.com/nginxinc/docker-nginx-unprivileged) in
order to make it more usable in various deployments.

Note that this Docker image changes the base image such that it has a default
`HOME` directory, and additionally `NGINX_CONF_DIR` and `NGINX_CONF_TMPL_DIR`,
which holds the NGINX configuration directory and template directory.

The default include glob `/etc/nginx/conf.d/*.conf` has been
removed, and is instead replaced with glob pattern `${NGINX_CONF_DIR}/*.conf`
for including new `nginx` conf files.

It is also possible to create reverse proxy for multiple locations, but this
would require use of configuration file instead of just environment variables
since it is not possible to represent array/map structures in environment
variables at the moment. See [Advanced-Section](#Advanced-Section) for details.

## Environment variables to override

By default `APPLY_TEMPLATE` is set to `"true"` and the start-up script will
perform a runtime interpolation of the configuration before running the NGINX
server.

If you are not interested in doing so, or prefer to just volume mount in the
`default.conf` file directly, set `APPLY_TEMPLATE` to `"false"` to prevent the
runtime interpolation.

Also if you prefer to use configuration file (TOML, JSON are supported) instead
of environment variables, you may apply the following key/value pairs below
in the configuration file instead. See [Advanced-Section](#Advanced-Section)
for details.

The rest are applicable when `APPLY_TEMPLATE` is set to `"true"`:

### Server block section

This section pertains to the `server` block in NGINX configuration.

- `LISTENING_PORT`
  - Listening address of the reverse proxy, e.g. `8080`
- `SERVER_NAME`
  - Server name label in the Nginx `server` block, e.g. `localhost`
- `USE_GZIP`
  - Turns on or off gzip compression on the server.
    Defaults to `off`.

### Location block section

This section pertains to the `location` block in NGINX configuration.

- `LOCATION`
  - Location to serve the proxy-pass, defaults to `/` to serve the reverse proxy
    at root path.
- `PROXY_PASS_URL`
  - URL to proxy pass into, e.g. `http://localhost:9090/`
- `PROXY_SET_HEADER_HOST`
  - Value to set into the `Host` header. Not setting it defaults it to
    `$proxy_host`, which is usually preferred.
- `PROXY_SET_HEADER_REFERER`
  - Value to set into the `Referer` header.
    Defaults to `"$http_referer"`
- `PROXY_SET_HEADER_X_FORWARDED_FOR`
  - Value to set into the `X-Forwarded-For` header.
    Defaults to `"$remote_addr"`
- `PROXY_SET_HEADER_X_FORWARDED_PROTO`
  - Value to set into the `X-Forwarded-Proto` header.
    Defaults to `"$scheme"`

Again, the start-up script is set to run
`${NGINX_CONF_TMPL_DIR}/default.conf.tmpl > ${NGINX_CONF_DIR}/default.conf`
unless `APPLY_TEMPLATE` is set to `"false"`.

## Advanced Section

You will need to set environment variable `CONTEXT_FILE` to the file path of
your context configuration file. The value must end with either `.toml` or
`.json` so that it is able to dynamically detect which file format to read the
file as. You will then need to either copy in or volume bind in this context
configuration file into the container. This method will render the default
environment variables meant to set up the NGINX configuration unused, which is
the intended effect.

All the fields in [Server block section](#Server-block-section) are still
relevant, and they need to be set in the context configuration file.

For the fields in [Location block section](#Location-block-section), they need
to be wrapped within `LOCATION_BLOCKS` array field. Do note that however,
`PROXY_SET_HEADER_REFERER`, `PROXY_SET_HEADER_X_FORWARDED_FOR`,
`PROXY_SET_HEADER_X_FORWARDED_PROTO` would
need to be explicitly set, since there is no easy way to set default values
for fields within array context.

### Context example and working set-up demo

See [TOML example](./example.toml) for a quick glance for the above set-up.

The corresponding example Docker run command would be as follow:

```bash
docker build . --build-arg "NGINX_IMAGE_TAG=1.15-alpine" -t guangie88/reverse-proxy:latest

docker run --rm -it \
    -p 8080:8080 \
    -v "$(pwd)/example.toml:/tmp/example.toml" \
    -e "CONTEXT_FILE=/tmp/example.toml" \
    guangie88/reverse-proxy:latest
```
