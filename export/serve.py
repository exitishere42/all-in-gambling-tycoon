import http.server
import socketserver
import os
import mimetypes

PORT = 8080
DIRECTORY = os.path.dirname(os.path.abspath(__file__))

mimetypes.add_type("application/wasm", ".wasm")
mimetypes.add_type("application/octet-stream", ".pck")

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        # Enable Cross-Origin Isolation for Godot Web WebAssembly if accessed
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()

class ReusableServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True

print(f"Starting mobile presentation server on 0.0.0.0:{PORT} from {DIRECTORY}")
with ReusableServer(("0.0.0.0", PORT), CustomHandler) as httpd:
    httpd.serve_forever()
