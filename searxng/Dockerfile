# SearXNG for PicoClaw on Railway: the official image, pinned by version and
# digest, plus a start script that writes a settings.yml with JSON output
# (PicoClaw's web_search tool needs it).
FROM docker.io/searxng/searxng:2026.11.19-368baa340@sha256:5b72d7ef63a3d214c2a690016ecf53a17f1ab7f02dcc4a1de1669837d9340fc9

COPY railway-start.sh /usr/local/searxng/railway-start.sh
RUN chmod 0755 /usr/local/searxng/railway-start.sh

ENTRYPOINT ["/usr/local/searxng/railway-start.sh"]
