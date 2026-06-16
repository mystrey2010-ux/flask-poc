# Containerized Flask + Nginx Proof of Concept (PoC)

This project serves as a production-ready, highly secure template for hosting Python Flask applications and static web projects. It utilizes Docker Desktop on Windows 11 backed by a WSL 2 Fedora distribution.

---

## Architecture Overview

* **Host OS:** Windows 11 Home/Pro (Primary Machine)
* **Linux Environment:** WSL 2 (Fedora Distribution)
* **Container Engine:** Docker Desktop for Windows (WSL 2 Backend integration enabled)
* **Storage Configuration:** * Project Source Files: Stored locally within the high-performance native WSL filesystem (`/home/mattwakeling/...`).
    * Docker Image/Container Data: Relocated to the external secondary drive (`E:\DockerStorage`) via Docker Desktop settings to protect the `C:\` drive system storage.

### Service Stack
1.  **Nginx (Reverse Proxy):** Acts as the public-facing edge shield container. Listens on port 80, safely handles client handshakes, drops invalid requests, and forwards valid web traffic internally.
2.  **Gunicorn (WSGI Production Server):** Runs inside the isolated Python application container. It utilizes a 3-worker process model to execute the Flask application Python logic stably.

---

## Directory Structure

Ensure your project environment is organized exactly as follows within the WSL directory:

```text
/home/mattwakeling/data/Programming/Python-Linux/projects/flask-poc/
│   app.py
│   Dockerfile
│   requirements.txt
│   docker-compose.yml
├───nginx/
│       nginx.conf
├───static/
│       style.css
└───templates/
        index.html
