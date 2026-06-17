from flask import Flask, render_template, request
from werkzeug.middleware.proxy_fix import ProxyFix
import logging

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

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/')
def home():
    # Log client IP for monitoring (remove debug prints in production)
    client_ip = request.remote_addr
    if client_ip and not client_ip.startswith('192.168.'):
        logger.info(f"Request from IP: {client_ip}")
    
    return render_template('index.html')

if __name__ == '__main__':
    # Ensure this port matches the port in your docker-compose.yml 
    # and your Nginx 'proxy_pass' directive (usually 8000).
    app.run(host='0.0.0.0', port=8000, debug=False)
