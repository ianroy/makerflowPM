#!/usr/bin/env python3
"""WSGI entry point for production deployment.

This file can be used with production WSGI servers like:
- Gunicorn: gunicorn wsgi:application
- uWSGI: uwsgi --http :8080 --wsgi-file wsgi.py
- Waitress: waitress-serve --port=8080 wsgi:application
"""

from app.flask_app import flask_app

# Standard WSGI application variable name
application = flask_app

if __name__ == "__main__":
    # For development only
    application.run()
