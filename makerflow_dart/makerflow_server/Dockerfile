# Serverpod server image for DigitalOcean App Platform (and any container host).
# Build context is the monorepo root `makerflow_dart/` (the server path-depends
# on ../makerflow_client), so DO's source_dir = makerflow_dart and
# dockerfile_path = makerflow_dart/makerflow_server/Dockerfile.

# ---- build: AOT-compile the server to a self-contained native exe ----
FROM dart:stable AS build
WORKDIR /build

# Copy only the packages the server needs, deps first for layer caching.
COPY makerflow_client/ makerflow_client/
COPY makerflow_shared/ makerflow_shared/
COPY makerflow_server/ makerflow_server/
# Defense in depth: local secrets must never reach an image layer, even if the
# build context includes them (the real guard is makerflow_dart/.dockerignore --
# which Docker only reads at the CONTEXT root, not next to this Dockerfile).
RUN rm -f makerflow_server/config/passwords.yaml

WORKDIR /build/makerflow_server
RUN dart pub get
RUN dart compile exe bin/main.dart -o /build/server

# ---- runtime: slim image with just the exe + config + migrations ----
FROM debian:bookworm-slim AS runtime
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /build/server /app/server
COPY --from=build /build/makerflow_server/config/ /app/config/
COPY --from=build /build/makerflow_server/migrations/ /app/migrations/
COPY makerflow_server/deploy/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# api / insights / web servers
EXPOSE 8080 8081 8082

# The entrypoint renders config/<mode>.yaml + passwords.yaml from env (DO
# managed-DB bindings + secrets), then applies migrations and serves.
ENTRYPOINT ["/app/entrypoint.sh"]
