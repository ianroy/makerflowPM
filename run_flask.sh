#!/bin/bash
# MakerFlow PM - Flask Startup Script

set -e

# Configuration
HOST="${MAKERSPACE_HOST:-127.0.0.1}"
PORT="${MAKERSPACE_PORT:-8080}"
WORKERS="${GUNICORN_WORKERS:-4}"
THREADS="${GUNICORN_THREADS:-2}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Change to script directory
cd "$(dirname "$0")"

echo -e "${BLUE}MakerFlow PM - Flask Version${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}No virtual environment found. Creating one...${NC}"
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate 2>/dev/null || . venv/bin/activate

# Install/upgrade dependencies
echo -e "${GREEN}Installing dependencies...${NC}"
pip install -q --upgrade pip
pip install -q -r requirements.txt

echo -e "${GREEN}Dependencies installed!${NC}\n"

# Determine which mode to run
MODE="${1:-development}"

if [ "$MODE" = "production" ] || [ "$MODE" = "prod" ]; then
    echo -e "${GREEN}Starting in PRODUCTION mode${NC}"
    echo -e "Host: ${HOST}"
    echo -e "Port: ${PORT}"
    echo -e "Workers: ${WORKERS}"
    echo -e "Threads: ${THREADS}\n"

    # Check if gunicorn is available
    if command -v gunicorn &> /dev/null; then
        exec gunicorn wsgi:application \
            --bind "${HOST}:${PORT}" \
            --workers "${WORKERS}" \
            --threads "${THREADS}" \
            --timeout 120 \
            --access-logfile - \
            --error-logfile - \
            --log-level info
    else
        echo -e "${YELLOW}Gunicorn not found, using Waitress...${NC}"
        exec waitress-serve \
            --host="${HOST}" \
            --port="${PORT}" \
            --threads="${THREADS}" \
            wsgi:application
    fi
else
    echo -e "${GREEN}Starting in DEVELOPMENT mode${NC}"
    echo -e "Host: ${HOST}"
    echo -e "Port: ${PORT}"
    echo -e "Debug: Enabled\n"

    export FLASK_APP=app/flask_app.py
    export FLASK_DEBUG=1

    exec python3 app/flask_app.py
fi
