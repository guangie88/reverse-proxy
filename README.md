# Reverse Proxy

Pure reverse proxy that allows use of env var for configuration.

## Environment variables to override

- `LISTENING_ADDR` - Listening address of the reverse proxy, e.g. `80`
- `SERVER_NAME` - Server name label in the Nginx `server` block, e.g. `localhost`
- `PROXY_PASS_URL` - URL to proxy pass into, e.g. `http://localhost:8080/`
