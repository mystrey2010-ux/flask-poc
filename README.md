# Containerized Flask + Nginx Proof of Concept (PoC)

This project serves as a production-ready, highly secure template for hosting Python Flask applications and static web projects. It utilizes Docker Desktop on Windows 11 backed by a WSL 2 Fedora distribution.

---

## Architecture Overview

* **Host OS:** Windows 11 Home/Pro (Primary Machine)
* **Linux Environment:** WSL 2 (Fedora Distribution)
* **Container Engine:** Docker Desktop for Windows (WSL 2 Backend integration enabled)
* **Storage Configuration:** 
    * Project Source Files: Stored locally within the high-performance native WSL filesystem (`/home/<username>/...`).
    * Docker Image/Container Data: Relocated to the external secondary drive (`E:\DockerStorage`) via Docker Desktop settings to protect the `C:\` drive system storage.

### Service Stack
1.  **Nginx (Reverse Proxy):** Acts as the public-facing edge shield container. Listens on port 80, safely handles client handshakes, drops invalid requests, and forwards valid web traffic internally.
2.  **Gunicorn (WSGI Production Server):** Runs inside the isolated Python application container. It utilizes a 3-worker process model to execute the Flask application Python logic stably.

---

## Secure Ecosystem Management

Start the Secure Ecosystem
Bash
```
docker compose up -d
```
Stop the Entire Stack Cleanly
Bash
```
docker compose down
```
Stream Live Combined Production Logs
Bash
```
docker compose logs -f
```
Inspect Single Component Logs
Bash
```
docker compose logs nginx
docker compose logs flask_app 
```

## SSL Certificate Management

The SSL certificate for `mw-nexus.duckdns.org` has been updated and now achieves an A+ rating from Qualys SSL Labs, indicating industry-standard security. The certificate was obtained using certbot in standalone mode with the following command:

Bash
```
docker run --rm -it \
  -p 80:80 \
  -v flask-poc_certbot-etc:/etc/letsencrypt \
  -v flask-poc_certbot-var:/var/www/certbot \
  certbot/certbot certonly --standalone \
  -d mw-nexus.duckdns.org \
  --email your-email@example.com \
  --agree-tos --no-eff-email
```

### Explanation of Commands:

*   `--rm`: Removes the container automatically after execution. This ensures that we don't leave behind any temporary containers from certbot.
*   `-it`: Starts an interactive TTY session for better debugging and monitoring during certificate acquisition.
*   `-p 80:80`: Maps port 80 of your host to port 80 in the container. This is necessary for HTTP-01 challenge validation by Let's Encrypt.
*   `-v flask-poc_certbot-etc:/etc/letsencrypt`: Mounts a volume named `flask-poc_certbot-etc` (which should be created earlier) at `/etc/letsencrypt`. This directory contains configuration files and certificates issued by Let's Encrypt.
*   `-v flask-poc_certbot-var:/var/www/certbot`: Mounts another volume, `flask-poc_certbot-var`, to the container's working directory. This is where certbot stores temporary files needed for validation.
*   `certbot/certbot certonly --standalone`: Runs certbot in standalone mode which creates a simple HTTP server to respond to Let’s Encrypt challenges on port 80 without needing an existing web server.
*   `-d mw-nexus.duckdns.org`: Specifies the domain name for which we're requesting the certificate.
*   `--email your-email@example.com`: Provides contact email address. This is required for Let's Encrypt to notify about issues with certificates (though --no-eff-email suppresses EFF notifications).
*   `--agree-tos`: Agrees to the Let's Encrypt Terms of Service automatically without user interaction.
*   `--no-eff-email`: Suppresses EFF notifications.

## Security Features Implemented

1. **Rate Limiting:** Nginx is configured with rate limiting to protect against DDoS and vulnerability scanning attacks. Limits requests to 5 per minute per IP with a burst capacity of 10 requests.
2. **IP Address Logging:** Nginx uses a custom log format that captures real IP addresses from the X-Forwarded-For header, which is processed by Flask's ProxyFix middleware.
3. **SSL/TLS Configuration:** Strong SSL protocols (TLSv1.2, TLSv1.3) and cipher suites are configured for secure communication with proper certificate validation.
4. **Security Headers:** Implements HTTP security headers like HSTS, XSS protection, frame options, and content type options to enhance application security.

## Application Structure

*   `app.py`: Main Flask application with ProxyFix configuration for handling reverse proxy headers.
*   `docker-compose.yml`: Docker Compose file defining services for Flask app, Nginx proxy, and Certbot.
*   `nginx/nginx.conf`: Nginx configuration with SSL setup and reverse proxy rules.
*   `templates/index.html`: Basic HTML template for the root page.
*   `static/style.css`: Basic CSS styling for the page.
*   `check_ips.sh`: Security monitoring script to analyze Nginx logs and identify potential malicious IP addresses.

## Security Monitoring

To analyze access logs and identify potential vulnerability scanners:

```bash
./check_ips.sh
```

This script will:
- Extract IP addresses from Nginx proxy logs
- Count and rank IP addresses by frequency
- Display the top IP addresses that may be scanning your system
- Save detailed analysis to `/tmp/ip_analysis.txt`

IPs with high request counts (especially requesting sensitive paths like `/.env`, `/config`, etc.) should be monitored and potentially blocked. The rate limiting configuration will automatically slow down excessive requests from these IPs.

