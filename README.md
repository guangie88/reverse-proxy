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

- `LISTENING_PORT`
  - Listening address of the reverse proxy, e.g. `8080`
- `SERVER_NAME`
  - Server name label in the Nginx `server` block, e.g. `localhost`
- `PROXY_PASS_URL`
  - URL to proxy pass into, e.g. `http://localhost:9090/`
- `APPLY_TEMPLATE`
  - Apply env var interpolation at runtime if set to true, defaults to `"true"`

The startup command is designed to run
`${HOME}/nginx/conf.d/default.conf.tmpl > ${HOME}/nginx/conf.d/default.conf`
unless `APPLY_TEMPLATE` is set to `"false"`.
