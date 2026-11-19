[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/picoclaw-2?utm_medium=integration&utm_source=button&utm_campaign=picoclaw)

# PicoClaw on Railway

A Railway template for [PicoClaw](https://github.com/sipeed/picoclaw), the ultra-lightweight personal AI assistant written in Go. It runs PicoClaw's official launcher image (web console plus gateway) with a password-protected dashboard, all state on a volume, and a private [SearXNG](https://github.com/searxng/searxng) so the agent's web search works without a search API key.

**Versions**
- PicoClaw `v0.3.1`: `docker.io/sipeed/picoclaw:v0.3.1-launcher@sha256:ed830c6cb71f59785062433159c45c2363465cd02046f8dd2822bd24a39510c2`
- SearXNG `2026.11.19-368baa340`: `docker.io/searxng/searxng:2026.11.19-368baa340@sha256:5b72d7ef63a3d214c2a690016ecf53a17f1ab7f02dcc4a1de1669837d9340fc9`

## What it deploys

| Service | Source | Public | Storage |
|---|---|---|---|
| `PicoClaw` | `picoclaw/` in this repo | Railway domain on port 18800, health check `/api/auth/status` | volume at `/root/.picoclaw` (config, credentials, workspace, sessions, memory, cron jobs, dashboard password hash) |
| `SearXNG` | `searxng/` in this repo | private only, health check `/healthz` | none (stateless; `settings.yml` is written on every boot) |

- **PicoClaw** runs `picoclaw-launcher`, the web console. It serves the dashboard (chat, models, credentials, channels, skills, tools, config, logs) and starts the PicoClaw **gateway** (`picoclaw gateway`) as a child process in the same container as soon as a default model with credentials is configured. The gateway runs the agent, the chat channels (Telegram, Discord, Slack, Matrix, WhatsApp and more), cron jobs and the heartbeat. Upstream's one-shot `picoclaw agent` CLI is not a service.
- **SearXNG** is the self-hosted metasearch engine that PicoClaw's `web_search` tool queries over Railway's private network (`PICOCLAW_TOOLS_WEB_SEARXNG_BASE_URL`). PicoClaw prefers it over its keyless fallbacks.
- **Dashboard login:** a password is generated at deploy time (`PICOCLAW_DASHBOARD_PASSWORD`). On the first boot the start script hands it to PicoClaw, which stores only a bcrypt hash on the volume. Later changes to the variable are ignored; change the password from the dashboard instead.

## Variables

`PicoClaw` service:

| Variable | Default | What it does |
|---|---|---|
| `PICOCLAW_DASHBOARD_PASSWORD` | `${{secret(24,…)}}` | Dashboard password, generated at deploy time and used on the first boot only |
| `PICOCLAW_TOOLS_WEB_SEARXNG_BASE_URL` | `http://${{SearXNG.RAILWAY_PRIVATE_DOMAIN}}:${{SearXNG.PORT}}` | The private SearXNG service used by `web_search` |
| `PORT` | `18800` | Port the dashboard listens on; the public domain points here |

`SearXNG` service: `SEARXNG_SECRET` (generated) and `PORT` (`8080`).

No model key is asked at deploy time: you add the model and its key in the dashboard, where PicoClaw stores it on the volume. Most PicoClaw config fields also have an environment name (`PICOCLAW_…`, listed in [`pkg/config/config.go`](https://github.com/sipeed/picoclaw/blob/v0.3.1/pkg/config/config.go) and the [tools reference](https://github.com/sipeed/picoclaw/blob/v0.3.1/docs/reference/tools_configuration.md)) and can be set as a service variable; a variable overrides the saved config on every start.

## After deploying

1. Open the `PicoClaw` service's domain. Copy `PICOCLAW_DASHBOARD_PASSWORD` from the service's **Variables** tab and log in.
2. Go to **Models**, add a model with your provider key (OpenAI, Anthropic, OpenRouter, Gemini, DeepSeek, any OpenAI-compatible API, and more) and make it the default. The launcher then starts the gateway.
3. Chat in the dashboard, or connect a channel under **Channels** (for example a Telegram bot token from @BotFather). Restrict who may talk to the bot with each channel's allow list.

Run one replica only: the gateway, sessions and the volume belong to a single instance.

## Updates

When this repo's `main` moves to a newer PicoClaw or SearXNG pin, Railway shows deployers an "update available" notice, and each deployer chooses when to apply it. `CHANGELOG.md` lists every version, breaking changes first. Everything you configure stays on the PicoClaw volume; PicoClaw migrates its own config format on start. Don't use the dashboard's built-in self-update: the next redeploy would replace it with the pinned image.

## Local test

```sh
docker build -t picoclaw-railway ./picoclaw
docker build -t searxng-railway ./searxng
docker network create picoclaw
docker run -d --name searxng --network picoclaw -e PORT=8080 -e SEARXNG_SECRET=$(openssl rand -hex 32) searxng-railway
docker run -d --name picoclaw --network picoclaw -p 18800:18800 -v picoclaw-data:/root/.picoclaw \
  -e PORT=18800 -e PICOCLAW_DASHBOARD_PASSWORD=choose-a-password \
  -e PICOCLAW_TOOLS_WEB_SEARXNG_BASE_URL=http://searxng:8080 picoclaw-railway
```

Then open http://localhost:18800.

PicoClaw is MIT-licensed by Sipeed and contributors; SearXNG is AGPL-3.0. This repo only packages their official images.
