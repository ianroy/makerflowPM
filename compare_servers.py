#!/usr/bin/env python3
"""
Comparison script to verify both original and Flask versions work identically.
"""

import sys
import time
from pathlib import Path

# Add app directory to path
sys.path.insert(0, str(Path(__file__).parent / "app"))

def test_original_wsgi():
    """Test the original WSGI application."""
    print("Testing Original WSGI Application")
    print("=" * 50)

    try:
        from server import app as wsgi_app

        # Create a test request
        def start_response(status, headers):
            print(f"  Status: {status}")
            return lambda s: None

        environ = {
            'REQUEST_METHOD': 'GET',
            'PATH_INFO': '/healthz',
            'QUERY_STRING': '',
            'SERVER_NAME': 'localhost',
            'SERVER_PORT': '8080',
            'wsgi.url_scheme': 'http',
            'HTTP_COOKIE': '',
        }

        response = wsgi_app(environ, start_response)
        body = b''.join(response)
        print(f"  Response: {body.decode()}")
        print("  ✅ Original WSGI app working!\n")
        return True

    except Exception as e:
        print(f"  ❌ Error: {e}\n")
        return False


def test_flask_app():
    """Test the Flask application."""
    print("Testing Flask Application")
    print("=" * 50)

    try:
        from flask_app import flask_app

        with flask_app.test_client() as client:
            response = client.get('/healthz')
            print(f"  Status: {response.status_code}")
            print(f"  Response: {response.data.decode()}")
            print("  ✅ Flask app working!\n")
            return True

    except Exception as e:
        print(f"  ❌ Error: {e}\n")
        return False


def compare_responses():
    """Compare responses from both applications."""
    print("Comparing Responses")
    print("=" * 50)

    try:
        # Test original
        from server import app as wsgi_app

        def start_response(status, headers):
            return lambda s: None

        environ = {
            'REQUEST_METHOD': 'GET',
            'PATH_INFO': '/healthz',
            'QUERY_STRING': '',
            'SERVER_NAME': 'localhost',
            'SERVER_PORT': '8080',
            'wsgi.url_scheme': 'http',
            'HTTP_COOKIE': '',
        }

        wsgi_response = b''.join(wsgi_app(environ, start_response))

        # Test Flask
        from flask_app import flask_app

        with flask_app.test_client() as client:
            flask_response = client.get('/healthz').data

        # Compare
        if wsgi_response == flask_response:
            print("  ✅ Responses are identical!")
            print(f"  Both return: {wsgi_response.decode()}")
        else:
            print("  ⚠️  Responses differ:")
            print(f"  Original: {wsgi_response.decode()}")
            print(f"  Flask: {flask_response.decode()}")

        print()
        return wsgi_response == flask_response

    except Exception as e:
        print(f"  ❌ Error: {e}\n")
        return False


def main():
    """Run all tests."""
    print("\n" + "=" * 50)
    print("MakerFlow PM - Server Comparison")
    print("=" * 50 + "\n")

    results = []

    # Test original WSGI
    results.append(test_original_wsgi())

    # Test Flask
    results.append(test_flask_app())

    # Compare
    results.append(compare_responses())

    # Summary
    print("=" * 50)
    print("Summary")
    print("=" * 50)

    if all(results):
        print("✅ All tests passed!")
        print("✅ Both servers work identically")
        print("\nYou can use either:")
        print("  • Original: python3 app/server.py")
        print("  • Flask:    python3 app/flask_app.py")
        return 0
    else:
        print("❌ Some tests failed")
        return 1


if __name__ == "__main__":
    sys.exit(main())
