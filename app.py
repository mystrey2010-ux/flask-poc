from flask import Flask, render_template, request
from werkzeug.middleware.proxy_fix import ProxyFix

app = Flask(__name__)

# Configure Flask to trust proxy headers. 
# x_for=2 is used because your traffic passes through both 
# the Windows NAT and the Docker internal bridge.
app.wsgi_app = ProxyFix(
    app.wsgi_app, 
    x_for=2, 
    x_proto=1, 
    x_host=1, 
    x_prefix=1
)

@app.route('/')
def home():
    # 1. Check the raw header coming from Nginx
    x_forwarded_for = request.headers.get('X-Forwarded-For')
    
    # 2. Check the IP after ProxyFix has processed the headers
    client_ip = request.remote_addr
    
    print(f"DEBUG: Raw X-Forwarded-For Header: {x_forwarded_for}")
    print(f"DEBUG: Final Client IP (parsed): {client_ip}")
    
    return render_template('index.html')

if __name__ == '__main__':
    # Ensure this port matches the port in your docker-compose.yml 
    # and your Nginx 'proxy_pass' directive (usually 8000).
    app.run(host='0.0.0.0', port=8000, debug=True)
