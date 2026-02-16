# Flask Migration Guide

This document explains how to run MakerFlow PM with Flask instead of the built-in WSGI server.

## Overview

The application has been converted to use Flask while preserving all existing functionality. The Flask version wraps the existing WSGI application, allowing for:

- Better development tools and debugging
- Easier integration with Flask extensions
- Production-ready WSGI servers (Gunicorn, Waitress)
- Flask CLI commands for management tasks
- Gradual migration path for converting routes to Flask-native code

## Installation

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

This will install:
- Flask and Werkzeug
- Gunicorn (Linux/Mac) or Waitress (Windows) for production

### 2. Verify Installation

```bash
python -c "import flask; print(f'Flask {flask.__version__} installed successfully')"
```

## Running the Application

### Development Mode

For development with auto-reload and debugging:

```bash
# Using Flask directly
cd /Users/bill/github/makerflowPM
python app/flask_app.py

# Or using Flask CLI
export FLASK_APP=app/flask_app.py
export FLASK_DEBUG=1
flask run --host=127.0.0.1 --port=8080
```

### Production Mode

#### Option 1: Gunicorn (Linux/Mac - Recommended)

```bash
# Single worker
gunicorn wsgi:application --bind 127.0.0.1:8080

# Multiple workers for better performance
gunicorn wsgi:application \
  --bind 127.0.0.1:8080 \
  --workers 4 \
  --threads 2 \
  --timeout 120 \
  --access-logfile - \
  --error-logfile -
```

#### Option 2: Waitress (Windows/Cross-platform)

```bash
waitress-serve --host=127.0.0.1 --port=8080 wsgi:application
```

#### Option 3: uWSGI

```bash
uwsgi --http :8080 --wsgi-file wsgi.py --callable application --processes 4 --threads 2
```

## Environment Variables

All existing environment variables still work:

```bash
export MAKERSPACE_DB_PATH="/path/to/database.db"
export MAKERSPACE_SECRET_KEY="your-secret-key-here"
export MAKERSPACE_HOST="0.0.0.0"
export MAKERSPACE_PORT="8080"
export FLASK_DEBUG="0"  # Set to 1 for development
```

## Flask CLI Commands

The Flask version adds helpful management commands:

```bash
# Initialize the database
flask --app app/flask_app init-db

# Run tests
flask --app app/flask_app run-tests

# Start development server
flask --app app/flask_app run
```

## Architecture

### How It Works

The Flask application uses a "bridge" pattern:

1. **Flask Routing**: Flask handles HTTP routing and request/response
2. **WSGI Bridge**: All requests are passed to the existing WSGI `app()` function
3. **Response Conversion**: WSGI responses are converted to Flask responses
4. **Full Compatibility**: All existing routes, logic, and features work unchanged

### File Structure

```
makerflowPM/
├── app/
│   ├── flask_app.py      # New Flask application
│   └── server.py          # Existing WSGI application (unchanged)
├── wsgi.py                # Production WSGI entry point
├── requirements.txt       # Updated with Flask dependencies
└── FLASK_MIGRATION.md     # This file
```

### Migration Strategy

The current implementation wraps the existing WSGI app. To gradually migrate to Flask-native routes:

1. Identify a route in `server.py` to migrate
2. Create a Flask route in `flask_app.py`
3. Import and call the existing handler functions
4. Test thoroughly
5. Remove the route from the WSGI catch-all

Example:

```python
# In flask_app.py
@flask_app.route('/api/tasks', methods=['GET'])
def api_tasks():
    from server import handle_api_tasks
    conn = db_connect()
    result = handle_api_tasks(conn, request)
    conn.close()
    return result
```

## Performance Considerations

### Gunicorn Workers

Calculate workers based on your system:
```
workers = (2 × CPU_cores) + 1
```

For a 4-core machine:
```bash
gunicorn wsgi:application --workers 9 --threads 2 --bind 0.0.0.0:8080
```

### Database Connections

Each worker has its own database connection pool. Monitor with:
```bash
# Check SQLite connections
lsof | grep makerspace_ops.db
```

### Memory Usage

Monitor with:
```bash
# Check memory per worker
ps aux | grep gunicorn
```

## Troubleshooting

### Import Errors

If you see import errors:
```bash
# Ensure you're in the project root
cd /Users/bill/github/makerflowPM

# Check Python path
python -c "import sys; print('\n'.join(sys.path))"
```

### Port Already in Use

```bash
# Find what's using the port
lsof -i :8080

# Kill the process
kill -9 <PID>
```

### Database Locked Errors

If you see "database is locked" errors with multiple workers:

1. Ensure WAL mode is enabled (it should be by default)
2. Reduce the number of workers
3. Increase `DB_BUSY_TIMEOUT_MS` environment variable

### Debug Mode Not Working

```bash
# Ensure FLASK_DEBUG is set
export FLASK_DEBUG=1
export FLASK_APP=app/flask_app.py
flask run
```

## Deployment Examples

### Systemd Service (Linux)

Create `/etc/systemd/system/makerflow.service`:

```ini
[Unit]
Description=MakerFlow PM Application
After=network.target

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=/opt/makerflowPM
Environment="PATH=/opt/makerflowPM/venv/bin"
Environment="MAKERSPACE_SECRET_KEY=change-this-in-production"
ExecStart=/opt/makerflowPM/venv/bin/gunicorn wsgi:application \
    --bind 127.0.0.1:8080 \
    --workers 4 \
    --timeout 120
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable makerflow
sudo systemctl start makerflow
sudo systemctl status makerflow
```

### Docker

Create `Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV MAKERSPACE_HOST=0.0.0.0
ENV MAKERSPACE_PORT=8080

CMD ["gunicorn", "wsgi:application", "--bind", "0.0.0.0:8080", "--workers", "4"]
```

Build and run:
```bash
docker build -t makerflow-pm .
docker run -p 8080:8080 -v ./data:/app/data makerflow-pm
```

### Nginx Reverse Proxy

```nginx
server {
    listen 80;
    server_name makerflow.example.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static/ {
        alias /opt/makerflowPM/app/static/;
        expires 30d;
    }
}
```

## Comparison: Original vs Flask

| Feature | Original (wsgiref) | Flask Version |
|---------|-------------------|---------------|
| Dependencies | None (stdlib only) | Flask, Gunicorn |
| Performance | Single-threaded | Multi-worker/Multi-threaded |
| Development | Basic | Auto-reload, debugger |
| Production Ready | Limited | Yes (Gunicorn/Waitress) |
| CLI Tools | None | Flask CLI commands |
| Extensions | None | Flask ecosystem available |
| Code Changes | N/A | Zero (wrapped) |

## Next Steps

1. **Test thoroughly**: Verify all routes work correctly
2. **Monitor performance**: Compare response times with original
3. **Gradual migration**: Convert routes to Flask-native over time
4. **Add extensions**: Consider Flask-Caching, Flask-Compress, etc.
5. **Production deployment**: Use Gunicorn with systemd or Docker

## Support

For issues specific to the Flask migration, check:
- Flask documentation: https://flask.palletsprojects.com/
- Gunicorn documentation: https://docs.gunicorn.org/
- This repository's issues: https://github.com/ianroy/makerflowPM/issues
