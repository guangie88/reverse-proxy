#!/usr/bin/env sh
set -euo pipefail

if [[ "${APPLY_TEMPLATE}" = "true" ]]; then
    if [[ "${CONTEXT_FILE:-.}" != "." ]]; then
        if echo -n "${CONTEXT_FILE}" | grep -E '\.toml$' >/dev/null; then
            TERA_CONTEXT="--toml ${CONTEXT_FILE}"
        elif echo -n "${CONTEXT_FILE}" | grep -E '\.json$' >/dev/null; then
            TERA_CONTEXT="--json ${CONTEXT_FILE}"
        else
            echo "Invalid context file format. Exiting."
            exit 1
        fi
    else
        TERA_CONTEXT="--env"
    fi

    tera -f ${HOME}/nginx/conf.d/default.conf.tmpl ${TERA_CONTEXT} \
        > ${HOME}/nginx/conf.d/default.conf
fi

exec nginx -g "daemon off;"
