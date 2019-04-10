#!/usr/bin/env sh
set -euo pipefail
if [[ "${APPLY_TEMPLATE}" = "true" ]]; then
    envja file ${HOME}/nginx/conf.d/default.conf.tmpl > ${HOME}/nginx/conf.d/default.conf;
fi

exec nginx -g "daemon off;"
