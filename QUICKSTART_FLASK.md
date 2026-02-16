# Quick Start - Flask Version

Get MakerFlow PM running with Flask in under 2 minutes.

## 1. Install Dependencies

```bash
pip install -r requirements.txt
```

## 2. Run the Application

### Development (with auto-reload)

```bash
./run_flask.sh
```

Or manually:
```bash
python3 app/flask_app.py
```

### Production

```bash
./run_flask.sh production
```

Or manually with Gunicorn:
```bash
gunicorn wsgi:application --bind 127.0.0.1:8080 --workers 4
```

## 3. Access the Application

Open your browser to: **http://127.0.0.1:8080**

## Configuration

Set environment variables before running:

```bash
export MAKERSPACE_HOST="0.0.0.0"          # Listen on all interfaces
export MAKERSPACE_PORT="8080"              # Port number
export MAKERSPACE_SECRET_KEY="random-key"  # Secret key for sessions
export MAKERSPACE_DB_PATH="./data/app.db"  # Database path
```

## What Changed?

- **Same features**: All existing functionality works identically
- **Better performance**: Multi-worker support with Gunicorn
- **Easier development**: Auto-reload and better error messages
- **Production ready**: Built-in support for production WSGI servers

## Troubleshooting

**Port in use?**
```bash
lsof -i :8080
kill -9 <PID>
```

**Import errors?**
```bash
cd /Users/bill/github/makerflowPM
export PYTHONPATH="$PWD:$PYTHONPATH"
```

**Database locked?**
```bash
# Reduce workers or ensure WAL mode
export MAKERSPACE_DB_JOURNAL_MODE="WAL"
```

## Next Steps

- Read [FLASK_MIGRATION.md](FLASK_MIGRATION.md) for detailed documentation
- Configure production deployment (systemd, Docker, etc.)
- Set up reverse proxy (nginx, Apache, etc.)
- Enable HTTPS for production use

## Comparison with Original

| Command | Original | Flask |
|---------|----------|-------|
| Run dev | `python3 app/server.py` | `python3 app/flask_app.py` |
| Run prod | Same (single-threaded) | `gunicorn wsgi:application` |
| Workers | 1 (threaded) | Configurable multi-worker |
| Reload | Manual restart | Auto-reload in dev mode |

Both versions are maintained and work identically!
