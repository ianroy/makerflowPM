#!/bin/sh
# Container entrypoint. Serverpod 3.x reads DB/Redis from config/<mode>.yaml and
# secrets from config/passwords.yaml — neither of which we bake into the image.
# DigitalOcean App Platform injects the managed-DB binding vars + secrets as env;
# we render the config files from them here, then apply migrations and serve.
set -eu

mode="${SERVERPOD_RUN_MODE:-production}"

: "${DATABASE_HOST:?DATABASE_HOST is required}"
: "${DATABASE_NAME:?DATABASE_NAME is required}"
: "${DATABASE_USER:?DATABASE_USER is required}"
: "${DATABASE_PASSWORD:?DATABASE_PASSWORD is required}"
: "${SERVICE_SECRET:?SERVICE_SECRET is required}"

cat > "/app/config/passwords.yaml" <<EOF
$mode:
  database: '${DATABASE_PASSWORD}'
  redis: '${REDIS_PASSWORD:-}'
  serviceSecret: '${SERVICE_SECRET}'
EOF

cat > "/app/config/${mode}.yaml" <<EOF
apiServer:
  port: 8080
  publicHost: ${PUBLIC_HOST:-localhost}
  publicPort: 443
  publicScheme: https
insightsServer:
  port: 8081
  publicHost: ${PUBLIC_HOST:-localhost}
  publicPort: 443
  publicScheme: https
webServer:
  port: 8082
  publicHost: ${PUBLIC_HOST:-localhost}
  publicPort: 443
  publicScheme: https
database:
  host: ${DATABASE_HOST}
  port: ${DATABASE_PORT:-5432}
  name: ${DATABASE_NAME}
  user: ${DATABASE_USER}
  requireSsl: ${DATABASE_REQUIRE_SSL:-true}
redis:
  enabled: ${REDIS_ENABLED:-true}
  host: ${REDIS_HOST:-localhost}
  port: ${REDIS_PORT:-6379}
  user: ${REDIS_USER:-default}
  requireSsl: ${REDIS_REQUIRE_SSL:-true}
EOF

# Apply pending migrations on boot, then serve (single-instance monolith).
# For multi-instance, run migrations once via a separate `--role maintenance`
# job and drop --apply-migrations here.
exec /app/server --mode "$mode" --apply-migrations --role monolith
