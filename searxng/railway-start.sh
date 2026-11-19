#!/bin/sh
# Writes settings.yml on every boot (this service is stateless: SearXNG keeps
# no data, so it has no volume) and hands over to the upstream entrypoint.
set -eu

conf_dir="${__SEARXNG_CONFIG_PATH:-/etc/searxng}"
settings="$conf_dir/settings.yml"

# Railway injects PORT; the upstream image listens on GRANIAN_PORT (8080).
if [ -n "${PORT:-}" ]; then
    export GRANIAN_PORT="$PORT"
fi

# A Railway service named "searxng" could leak a non-numeric SEARXNG_PORT.
case "${SEARXNG_PORT:-}" in
    *[!0-9]*) unset SEARXNG_PORT ;;
esac

[ -n "${SEARXNG_SECRET:-}" ] || { echo "railway-start: SEARXNG_SECRET is not set" >&2; exit 1; }

mkdir -p "$conf_dir"
cat > "$settings" <<'YAML'
# Written by the PicoClaw Railway template on every boot. Reference:
# https://docs.searxng.org/admin/settings/index.html
use_default_settings: true

server:
  # The secret key comes from the SEARXNG_SECRET variable.
  # Private service: only PicoClaw reaches it, so the bot limiter stays off.
  limiter: false
  public_instance: false
  image_proxy: false
  method: "GET"

search:
  formats:
    - html
    - json
YAML

exec /usr/local/searxng/entrypoint.sh "$@"
