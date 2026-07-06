#!/usr/bin/env python3
"""Servidor local con headers COOP/COEP para Godot web exports."""
import http.server
import os

PORT = 8080
WEB_DIR = os.path.dirname(os.path.abspath(__file__))

class GodotHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

    def log_message(self, format, *args):
        pass  # silenciar logs

if __name__ == "__main__":
    with http.server.HTTPServer(("", PORT), GodotHandler) as httpd:
        print(f"Servidor Godot en http://localhost:{PORT}")
        print("Ctrl+C para detener")
        httpd.serve_forever()
