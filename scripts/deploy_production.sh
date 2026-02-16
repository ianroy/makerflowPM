#!/usr/bin/env bash
set -euo pipefail

# Production deploy helper for MakerFlow PM.
# Decision notes:
# - Keeps infra simple (systemd + nginx + certbot) for low-cost departmental hosting.
# - Uses a staging copy in /tmp and atomic rsync into /opt to avoid partial deploys.
# - Leaves DB file untouched between deploys so operational data is preserved.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SSH_TARGET=""
DOMAIN=""
APP_DIR="/opt/makerflow-pm"
SERVICE_NAME="makerflow"
APP_USER="makerflow"
ADMIN_EMAIL=""
ADMIN_PASSWORD=""
SECRET_KEY=""
LETSENCRYPT_EMAIL=""
WITH_CERTBOT="1"
ENABLE_UFW="1"
ENABLE_SWAP="1"
SWAP_GB="2"

usage() {
  cat <<'USAGE'
Usage:
  scripts/deploy_production.sh \
    --ssh user@server \
    --domain makerflow.org \
    --admin-email admin@yourdomain.edu \
    --admin-password 'StrongPasswordHere' \
    [--letsencrypt-email ops@yourdomain.edu] \
    [--app-dir /opt/makerflow-pm] \
    [--service-name makerflow] \
    [--no-certbot] \
    [--no-ufw] \
    [--no-swap] \
    [--swap-gb 2]

Notes:
  - Run from a checked-out repository copy.
  - SSH user must have sudo privileges.
  - DNS for --domain should already point to the server before certbot.
  - Defaults are tuned for low-cost DigitalOcean droplets (2 GB swap, UFW enabled).
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ssh)
      SSH_TARGET="${2:-}"
      shift 2
      ;;
    --domain)
      DOMAIN="${2:-}"
      shift 2
      ;;
    --app-dir)
      APP_DIR="${2:-}"
      shift 2
      ;;
    --service-name)
      SERVICE_NAME="${2:-}"
      shift 2
      ;;
    --admin-email)
      ADMIN_EMAIL="${2:-}"
      shift 2
      ;;
    --admin-password)
      ADMIN_PASSWORD="${2:-}"
      shift 2
      ;;
    --secret-key)
      SECRET_KEY="${2:-}"
      shift 2
      ;;
    --letsencrypt-email)
      LETSENCRYPT_EMAIL="${2:-}"
      shift 2
      ;;
    --no-certbot)
      WITH_CERTBOT="0"
      shift
      ;;
    --no-ufw)
      ENABLE_UFW="0"
      shift
      ;;
    --no-swap)
      ENABLE_SWAP="0"
      shift
      ;;
    --swap-gb)
      SWAP_GB="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$SSH_TARGET" || -z "$DOMAIN" || -z "$ADMIN_EMAIL" || -z "$ADMIN_PASSWORD" ]]; then
  echo "Missing required flags." >&2
  usage
  exit 1
fi

if [[ ! "$SWAP_GB" =~ ^[0-9]+$ ]]; then
  echo "--swap-gb must be a positive integer." >&2
  exit 1
fi

if [[ -z "$LETSENCRYPT_EMAIL" ]]; then
  LETSENCRYPT_EMAIL="$ADMIN_EMAIL"
fi

if [[ -z "$SECRET_KEY" ]]; then
  SECRET_KEY="$(python3 - <<'PY'
import secrets
print(secrets.token_urlsafe(64))
PY
)"
fi

if ! command -v ssh >/dev/null 2>&1; then
  echo "ssh not found." >&2
  exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
  echo "tar not found." >&2
  exit 1
fi

STAGE_DIR="/tmp/makerflow-deploy-$(date +%s)"
SECRET_KEY_B64="$(printf '%s' "$SECRET_KEY" | base64 | tr -d '\n')"
ADMIN_PASSWORD_B64="$(printf '%s' "$ADMIN_PASSWORD" | base64 | tr -d '\n')"

echo "Uploading project to $SSH_TARGET:$STAGE_DIR ..."
tar \
  --exclude='.git' \
  --exclude='.venv' \
  --exclude='tmp' \
  --exclude='analysis_outputs' \
  --exclude='data/makerspace_ops.db' \
  --exclude='data/backups' \
  -czf - -C "$PROJECT_DIR" . \
| ssh "$SSH_TARGET" "rm -rf '$STAGE_DIR' && mkdir -p '$STAGE_DIR' && tar -xzf - -C '$STAGE_DIR'"

echo "Configuring server ..."
ssh "$SSH_TARGET" \
  "DOMAIN='$DOMAIN' APP_DIR='$APP_DIR' SERVICE_NAME='$SERVICE_NAME' APP_USER='$APP_USER' ADMIN_EMAIL='$ADMIN_EMAIL' LETSENCRYPT_EMAIL='$LETSENCRYPT_EMAIL' WITH_CERTBOT='$WITH_CERTBOT' ENABLE_UFW='$ENABLE_UFW' ENABLE_SWAP='$ENABLE_SWAP' SWAP_GB='$SWAP_GB' STAGE_DIR='$STAGE_DIR' SECRET_KEY_B64='$SECRET_KEY_B64' ADMIN_PASSWORD_B64='$ADMIN_PASSWORD_B64' bash -s" <<'REMOTE'
set -euo pipefail

SECRET_KEY="$(printf '%s' "$SECRET_KEY_B64" | base64 -d)"
ADMIN_PASSWORD="$(printf '%s' "$ADMIN_PASSWORD_B64" | base64 -d)"

sudo apt-get update
sudo apt-get install -y python3 python3-venv nginx certbot python3-certbot-nginx rsync curl ufw

if ! id -u "$APP_USER" >/dev/null 2>&1; then
  sudo useradd --system --home "$APP_DIR" --shell /usr/sbin/nologin "$APP_USER"
fi

sudo mkdir -p "$APP_DIR"
sudo rsync -a --delete "$STAGE_DIR"/ "$APP_DIR"/
sudo mkdir -p "$APP_DIR/data" "$APP_DIR/tmp"
sudo chown -R "$APP_USER:$APP_USER" "$APP_DIR"
sudo rm -rf "$STAGE_DIR"

if [[ "$ENABLE_SWAP" == "1" ]] && ! sudo swapon --show | grep -q "/swapfile"; then
  sudo fallocate -l "${SWAP_GB}G" /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count="$((SWAP_GB * 1024))" status=progress
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  if ! grep -q '^/swapfile ' /etc/fstab; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
  fi
  echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-makerflow-swap.conf >/dev/null
  echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.d/99-makerflow-swap.conf >/dev/null
  sudo sysctl --system >/dev/null
fi

sudo tee "$APP_DIR/.env" >/dev/null <<ENV
MAKERSPACE_SECRET_KEY=$SECRET_KEY
MAKERSPACE_COOKIE_SECURE=1
MAKERSPACE_HOST=127.0.0.1
MAKERSPACE_PORT=8080
MAKERSPACE_SESSION_DAYS=14
MAKERSPACE_DEFAULT_ORG_NAME=Default Workspace
MAKERSPACE_DEFAULT_ORG_SLUG=default
MAKERSPACE_WSGI_THREADED=1
MAKERSPACE_DB_JOURNAL_MODE=WAL
MAKERSPACE_DB_SYNCHRONOUS=NORMAL
MAKERSPACE_DB_BUSY_TIMEOUT_MS=7000
MAKERSPACE_DB_CACHE_SIZE_KB=65536
MAKERSPACE_DB_MMAP_SIZE_BYTES=268435456
MAKERSPACE_DB_TEMP_STORE_MEMORY=1
MAKERSPACE_ADMIN_EMAIL=$ADMIN_EMAIL
MAKERSPACE_ADMIN_PASSWORD=$ADMIN_PASSWORD
ENV
sudo chown "$APP_USER:$APP_USER" "$APP_DIR/.env"
sudo chmod 600 "$APP_DIR/.env"

sudo -u "$APP_USER" python3 -m venv "$APP_DIR/.venv"
if [[ -f "$APP_DIR/requirements.txt" ]] && grep -Eq '^[A-Za-z0-9]' "$APP_DIR/requirements.txt"; then
  sudo -u "$APP_USER" "$APP_DIR/.venv/bin/pip" install --upgrade pip wheel
  sudo -u "$APP_USER" "$APP_DIR/.venv/bin/pip" install -r "$APP_DIR/requirements.txt"
fi

sudo tee "/etc/systemd/system/${SERVICE_NAME}.service" >/dev/null <<UNIT
[Unit]
Description=MakerFlow PM
After=network.target

[Service]
User=$APP_USER
Group=$APP_USER
WorkingDirectory=$APP_DIR
EnvironmentFile=$APP_DIR/.env
Environment=PYTHONUNBUFFERED=1
Environment=PYTHONDONTWRITEBYTECODE=1
ExecStart=$APP_DIR/.venv/bin/python -u $APP_DIR/app/server.py
Restart=always
RestartSec=3
TimeoutStartSec=30
TimeoutStopSec=20
NoNewPrivileges=true
PrivateTmp=true
PrivateDevices=true
ProtectHome=true
ProtectSystem=full
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelTunables=true
RestrictSUIDSGID=true
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
SystemCallArchitectures=native
CapabilityBoundingSet=
AmbientCapabilities=
LockPersonality=true
MemoryDenyWriteExecute=true
UMask=027
LimitNOFILE=65536
ReadWritePaths=$APP_DIR/data $APP_DIR/tmp

[Install]
WantedBy=multi-user.target
UNIT

sudo tee "/etc/nginx/sites-available/${SERVICE_NAME}" >/dev/null <<NGINX
server {
    listen 80;
    server_name $DOMAIN;

    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
    add_header Referrer-Policy strict-origin-when-cross-origin;
    add_header Permissions-Policy "camera=(), microphone=(), geolocation=()";

    client_max_body_size 25m;
    keepalive_timeout 65s;
    gzip on;
    gzip_types text/plain text/css application/json application/javascript application/xml image/svg+xml;
    gzip_min_length 512;
    proxy_read_timeout 120s;
    proxy_send_timeout 120s;
    proxy_connect_timeout 10s;

    location /static/ {
        alias $APP_DIR/app/static/;
        access_log off;
        expires 7d;
        add_header Cache-Control "public, max-age=604800, immutable";
        try_files \$uri =404;
    }

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
NGINX

if [[ ! -L "/etc/nginx/sites-enabled/${SERVICE_NAME}" ]]; then
  sudo ln -s "/etc/nginx/sites-available/${SERVICE_NAME}" "/etc/nginx/sites-enabled/${SERVICE_NAME}"
fi

if [[ -f /etc/nginx/sites-enabled/default ]]; then
  sudo rm -f /etc/nginx/sites-enabled/default
fi

sudo nginx -t
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME"
sudo systemctl reload nginx

READY_OK="0"
for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:8080/readyz" >/dev/null; then
    READY_OK="1"
    break
  fi
  sleep 1
done
if [[ "$READY_OK" != "1" ]]; then
  echo "Application readiness check failed. Recent logs:"
  sudo journalctl -u "$SERVICE_NAME" -n 120 --no-pager
  exit 1
fi

if [[ "$WITH_CERTBOT" == "1" ]]; then
  sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$LETSENCRYPT_EMAIL" --redirect
fi

if [[ "$ENABLE_UFW" == "1" ]]; then
  sudo ufw allow OpenSSH
  sudo ufw allow 'Nginx Full'
  sudo ufw --force enable
fi

# Daily DB backup at 02:15 server time.
CRON_LINE="15 2 * * * $APP_DIR/scripts/backup_db.sh >/dev/null 2>&1"
if ! sudo crontab -u "$APP_USER" -l 2>/dev/null | grep -Fq "$APP_DIR/scripts/backup_db.sh"; then
  (sudo crontab -u "$APP_USER" -l 2>/dev/null; echo "$CRON_LINE") | sudo crontab -u "$APP_USER" -
fi

echo "Deploy complete."
echo "Health check: curl -i http://127.0.0.1:8080/healthz"
echo "Readiness check: curl -i http://127.0.0.1:8080/readyz"
echo "App URL: https://$DOMAIN/login"
REMOTE

echo
echo "Done. Next steps:"
echo "1) Open https://$DOMAIN/login"
echo "2) Rotate bootstrap passwords immediately"
echo "3) Verify backups in $APP_DIR/data/backups after first nightly run"
