#!/usr/bin/env python3
"""MakerFlow Platform - Flask Application

A Flask-based version of the MakerFlow PM platform.
This wraps the existing WSGI application logic in Flask routes.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path
from typing import Dict, Any

from flask import Flask, request, g
from werkzeug.wrappers import Response as WerkzeugResponse

# Add the app directory to the path so we can import server
sys.path.insert(0, str(Path(__file__).parent))

# Import the existing WSGI application and necessary components
from server import (
    # Configuration
    APP_NAME,
    BASE_DIR,
    DATA_DIR,
    STATIC_DIR,
    WEBSITE_DIR,
    DB_PATH,
    SECRET_KEY,
    COOKIE_SECURE,
    SESSION_DAYS,
    HOST,
    PORT,
    # The main WSGI app function
    app as wsgi_app,
    ensure_bootstrap,
)

# Create Flask app
flask_app = Flask(__name__,
                  static_folder=None,  # We'll handle static files through the WSGI app
                  template_folder=None)  # Using custom rendering

flask_app.config['SECRET_KEY'] = SECRET_KEY
flask_app.config['SESSION_COOKIE_SECURE'] = COOKIE_SECURE
flask_app.config['SESSION_COOKIE_HTTPONLY'] = True
flask_app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'


class FlaskWSGIBridge:
    """Bridge between Flask and the existing WSGI application.

    This allows us to use Flask's routing and middleware while
    preserving all the existing WSGI application logic.
    """

    def __init__(self, wsgi_application):
        self.wsgi_app = wsgi_application

    def __call__(self, environ: Dict[str, Any], start_response):
        """WSGI interface that delegates to the wrapped application."""
        return self.wsgi_app(environ, start_response)


# Wrap the existing WSGI app with Flask
@flask_app.before_request
def setup_request():
    """Initialize request context."""
    # Health probes must remain lightweight and should not depend on full DB bootstrap.
    # This prevents deployment health checks from failing before migrations can be diagnosed.
    if request.path in {"/healthz"}:
        return None
    ensure_bootstrap()


@flask_app.route('/', defaults={'path': ''}, methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH'])
@flask_app.route('/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH'])
def catch_all(path):
    """
    Catch-all route that delegates to the existing WSGI application.

    This preserves all existing routing logic while running under Flask.
    """
    # Create a custom start_response that captures the response
    response_data = {}

    def start_response(status, headers, exc_info=None):
        response_data['status'] = status
        response_data['headers'] = headers
        return lambda s: None  # Return a dummy write function

    # Call the original WSGI app
    response_body = wsgi_app(request.environ, start_response)

    # Convert WSGI response to Flask response
    if isinstance(response_body, list):
        body = b''.join(response_body)
    else:
        body = b''.join(list(response_body))

    # Parse status code
    status_code = int(response_data.get('status', '200 OK').split()[0])

    # Create Flask response
    response = flask_app.make_response((body, status_code))

    # Apply headers from WSGI app
    for header_name, header_value in response_data.get('headers', []):
        response.headers[header_name] = header_value

    return response


# Flask-specific utilities and enhancements can be added here
@flask_app.cli.command()
def init_db():
    """Initialize the database (Flask CLI command)."""
    from server import init_db as server_init_db
    server_init_db()
    print("Database initialized successfully!")


@flask_app.cli.command()
def run_tests():
    """Run application tests (Flask CLI command)."""
    print("Running tests...")
    import subprocess
    subprocess.run([sys.executable, "-m", "pytest", "tests/"], cwd=str(BASE_DIR))


if __name__ == '__main__':
    # Run with Flask's development server
    # In production, use: gunicorn or waitress
    flask_app.run(
        host=HOST,
        port=PORT,
        debug=os.environ.get('FLASK_DEBUG', '0') == '1',
        threaded=True
    )
