# Changelog

Each entry lists breaking changes first. Railway deployers see an "update available" notice when `main` changes; read the entry before you apply it.

## 2026-11-19: PicoClaw v0.3.1, SearXNG 2026.11.19-368baa340

First release of the template.

- `PicoClaw`: `docker.io/sipeed/picoclaw:v0.3.1-launcher@sha256:ed830c6cb71f59785062433159c45c2363465cd02046f8dd2822bd24a39510c2` (web console plus gateway), state on a volume at `/root/.picoclaw`, dashboard password generated at deploy time.
- `SearXNG`: `docker.io/searxng/searxng:2026.11.19-368baa340@sha256:5b72d7ef63a3d214c2a690016ecf53a17f1ab7f02dcc4a1de1669837d9340fc9`, private, used by PicoClaw's `web_search` tool.
