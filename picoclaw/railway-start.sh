#!/bin/sh
# Start script for the PicoClaw Railway template.
# - keeps all state in $PICOCLAW_HOME (a Railway volume),
# - sets the dashboard password from PICOCLAW_DASHBOARD_PASSWORD on first boot,
# - points PicoClaw's web search at the bundled SearXNG service,
# - starts the launcher (web console) on Railway's PORT; the launcher runs the
#   gateway as a child process once a model is configured.
set -eu

export PICOCLAW_HOME="${PICOCLAW_HOME:-/root/.picoclaw}"
mkdir -p "$PICOCLAW_HOME"
port="${PORT:-18800}"

# A PID file left by the previous container would point at a dead process.
rm -f "$PICOCLAW_HOME/.picoclaw.pid"

# First boot: hand the generated password to the launcher. PicoClaw's own
# one-time migration stores it as a bcrypt hash in launcher-auth.db and removes
# it from launcher-config.json. It never replaces a password that is already set.
launcher_cfg="$PICOCLAW_HOME/launcher-config.json"
pw="${PICOCLAW_DASHBOARD_PASSWORD:-}"
if [ ! -f "$launcher_cfg" ]; then
    case "$pw" in
        "")
            echo "railway-start: PICOCLAW_DASHBOARD_PASSWORD is empty; open /launcher-setup to choose a password." >&2 ;;
        *[!A-Za-z0-9._~-]*)
            echo "railway-start: PICOCLAW_DASHBOARD_PASSWORD may only use letters, digits and ._~- ; open /launcher-setup instead." >&2 ;;
        *)
            printf '{\n  "port": %s,\n  "public": true,\n  "allow_localhost_bypass": true,\n  "launcher_token": "%s"\n}\n' "$port" "$pw" > "$launcher_cfg"
            chmod 600 "$launcher_cfg"
            echo "railway-start: dashboard password set from PICOCLAW_DASHBOARD_PASSWORD (first boot)." ;;
    esac
fi
# Keep the password out of the gateway's and the agent's environment.
unset PICOCLAW_DASHBOARD_PASSWORD
pw=""

# Web search through the bundled SearXNG service (private network, no API key).
if [ -n "${PICOCLAW_TOOLS_WEB_SEARXNG_BASE_URL:-}" ]; then
    export PICOCLAW_TOOLS_WEB_SEARXNG_ENABLED="${PICOCLAW_TOOLS_WEB_SEARXNG_ENABLED:-true}"
fi

exec picoclaw-launcher -console -public -no-browser -port "$port" "$@"
