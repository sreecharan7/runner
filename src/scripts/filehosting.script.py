import http.server
import socketserver
import urllib.parse
import socket
import argparse
import os
import sys

# Default password if not specified
DEFAULT_PASSWORD = ''

class RequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        self.file_path = kwargs.pop('file_path', 'example.txt')
        self.password = kwargs.pop('password', DEFAULT_PASSWORD)
        super().__init__(*args, **kwargs)
    
    def do_GET(self):
        """Serve a GET request."""
        if self.send_head():
            return
    
    def send_head(self):
        """Override to serve a specific file after optional password authentication."""
        parsed_path = urllib.parse.urlparse(self.path)
        query_params = urllib.parse.parse_qs(parsed_path.query)
        
        # Get the password from the URL query parameters
        provided_password = query_params.get('password', [None])[0]
        
        # Check if password matches or if no password is required
        if provided_password == self.password or self.password is None:
            self.path = self.file_path
            print(f"Serving file: {self.file_path}")
            if os.path.isfile(self.file_path):
                print(f"File {self.file_path} exists and is being served.")
                self.send_response(200)
                self.send_header("Content-type", "application/octet-stream")
                self.send_header("Content-Disposition", f"attachment; filename={os.path.basename(self.file_path)}")
                self.send_header("Content-Length", os.path.getsize(self.file_path))
                self.end_headers()
                
                with open(self.file_path, 'rb') as file:
                    self.wfile.write(file.read())
                return True
            else:
                print(f"File {self.file_path} does not exist.")
                self.send_response(404)
                self.end_headers()
                return False
        else:
            self.send_response(403)
            self.end_headers()
            return False

def find_free_port(start_port):
    """Find a free port starting from the specified port."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        while True:
            try:
                s.bind(('', start_port))
                s.listen(1)
                return start_port
            except OSError:
                start_port += 1

def run_server(port, file_path, password):
    handler = lambda *args, **kwargs: RequestHandler(*args, file_path=file_path, password=password, **kwargs)
    httpd = socketserver.TCPServer(("", port), handler)
    httpd.serve_forever()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Serve a file over HTTP with optional password protection.')
    parser.add_argument('file_path', type=str, help='Path to the file to serve')
    parser.add_argument('--password', type=str, nargs='?', default=DEFAULT_PASSWORD, help='Password required for access (leave empty for no password)')
    
    args = parser.parse_args()

    password = args.password if args.password is not None else DEFAULT_PASSWORD
    
    # Check if the file path is valid
    if not os.path.isfile(args.file_path):
        print(f"Error: The file '{args.file_path}' does not exist or is not a file.")
        sys.exit(1)
    
    port = find_free_port(10584)
    os.environ['PORTSERVER'] = str(port) 
    
    run_server(port, args.file_path, args.password)