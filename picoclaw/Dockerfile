# PicoClaw on Railway: the official launcher image (web console + gateway),
# pinned by version and digest, plus a small start script.
# Update: bump the tag and digest below, add a CHANGELOG.md entry, merge to main.
FROM docker.io/sipeed/picoclaw:v0.3.1-launcher@sha256:ed830c6cb71f59785062433159c45c2363465cd02046f8dd2822bd24a39510c2

COPY railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 0755 /usr/local/bin/railway-start.sh

ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
