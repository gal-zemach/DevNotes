
# DevNotes — Containerized Full-Stack Notes App
> A simple, self-contained setup that demonstrates Dockerized deployment, local Kubernetes (kind) orchestration, and Jenkins CI/CD.

DevNotes is a solo, self-contained project demonstrating how to:

1. Containerize a simple full-stack app,
2. Deploy it to a local Kubernetes cluster (kind) with state persisted via a PVC,
3. Automate builds/deploys via a Jenkins job.

This README covers the project’s purpose, architecture, and setup steps.

## Table of Contents
- [Project Purpose](#project-purpose)
- [System Overview](#system-overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
  - [Docker Compose](#option-1-docker-compose)
  - [Kubernetes with kind](#option-2-kubernetes-with-kind)
  - [Jenkins CI/CD](#option-3-jenkins-cicd)
- [Jenkins-in-Docker First-Time Setup](#jenkins-in-docker-first-time-setup)
- [Kubernetes Fixed Ports](#kubernetes-fixed-ports)
- [Next Steps and Future Improvements](#next-steps-and-future-improvements)

---

## Project Purpose

DevNotes aims to:

- Show how to package backend and frontend into separate Docker images  
- Demonstrate how to deploy a multi-service app with Kubernetes (kind) manifests  
- Illustrate persistent storage via a PVC that survives pod restarts (but not cluster deletion)  
- Provide a simple Jenkins CI/CD pipeline for building images and deploying to kind  

The actual “notes” app is trivial (create/read simple text entries), as the focus is on the container/cluster setup.

---

## System Overview

### Components

1. **The DevNotes App**  
   - A fullstack app for note-taking. Consists of:  
     - **Backend**, located in `backend/`  
       - A small Flask app that handles GET and POST requests for notes.  
       - It stores data in a local `notes.json` file.  
     - **Frontend**, located in `frontend/`  
       - A static HTML page served with Nginx. It lets users submit new notes and view existing ones by calling the backend API.


2. **Docker Compose**  
   - `docker-compose.yml` (root of repo)  
   - Spins up both services and mounts a volume to preserve note data between runs.  
   - Unused if you're using Kubernetes, but convenient for local development.


3. **Kubernetes (kind)**  
   - Runs the app in a local cluster emulating a production-like environment.  
   - YAML manifests are under `k8s/`:  
     - `backend-deployment.yaml`, `backend-service.yaml` – deploy and expose the backend  
     - `frontend-deployment.yaml`, `frontend-service.yaml` – deploy and expose the frontend  
     - `persistent-volume.yaml`, `persistent-volume-claim.yaml` – enable note persistence  
     - `ingress.yaml` – enables a single access point via port 30080  
     - `kind-config.yaml` – configures kind to expose fixed ports


4. **(Optional) Jenkins CI/CD**  
   - Automates Docker builds and deployment to the cluster  
   - Configuration lives in `jenkins/` and the root `Jenkinsfile`

---

## Prerequisites

To run this project, make sure you have the following installed on your machine:

- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)**
- **[kubectl](https://kubernetes.io/docs/tasks/tools/)**
- **[kind](https://kind.sigs.k8s.io/)**
- **[Git](https://git-scm.com/)**

If you're on macOS with Homebrew installed:
```bash
brew install docker kubectl kind git
```

### Jenkins (Optional, for CI/CD automation)

You can install Jenkins manually or simply use the provided Docker setup:

```bash
cd jenkins
docker-compose up --build -d
```

If using this method, see [Jenkins-in-Docker First-Time Setup](#jenkins-in-docker-first-time-setup).

---

## Usage

How to start, use, and stop the project using Docker Compose, Kubernetes, or Jenkins.

### Option 1: Docker Compose

**Start everything:**
```bash
docker-compose up --build
```

**Use the app:**
- Backend: [http://localhost:5001/notes](http://localhost:5001/notes)
- Frontend: [http://localhost:8000](http://localhost:8000)

**Stop everything:**
```bash
docker-compose down
```

---

### Option 2: Kubernetes with kind

**Start everything:**

To save time, run the provided bootstrap script (`bootstrap-kind.sh`), which creates the cluster, builds & loads images, and applies manifests in order.

```bash
./bootstrap-kind.sh
```

**Use the app:**
- Frontend: [http://localhost:30080](http://localhost:30080)  
- The frontend internally calls the backend API

**Stop everything:**
```bash
kind delete cluster --name devnotes
```

---

### Option 3: Jenkins CI/CD

**Start Jenkins:**
```bash
cd jenkins
docker-compose up --build -d
```

**Access Jenkins UI:**
- Visit [http://localhost:8081](http://localhost:8081)

**Run the pipeline:**
- Create a classic job using the `Jenkinsfile` at the root of the repo  
- Run the job to build, load, and deploy to kind

**Use the app (after the job runs):**
- Visit [http://localhost:30080](http://localhost:30080)

**Stop Jenkins:**
```bash
cd jenkins
docker-compose down
```

---

## Jenkins-in-Docker First-Time Setup

Because Docker containers don’t share the host’s `127.0.0.1`, Jenkins needs to talk to the cluster at `host.docker.internal` instead.

We patch your `kubeconfig` to reflect this.

From inside the project folder, run:
```bash
kubectl config view --raw --minify --context=kind-devnotes   | sed 's|https://127.0.0.1:|https://host.docker.internal:|; s|https://0.0.0.0:|https://host.docker.internal:|'   > ./jenkins/kubeconfig.patched
```

If you run into TLS issues inside Jenkins, open `kubeconfig.patched` and replace:
```yaml
certificate-authority-data: ...
```
with:
```yaml
insecure-skip-tls-verify: true
```

This allows Jenkins to connect without verifying TLS certificates.

---

## Kubernetes Fixed Ports

These port mappings come from `k8s/kind-config.yaml`.

| Purpose                          | Host Address      | Container Port |
|----------------------------------|-------------------|----------------|
| **Backend (Flask API)**          | `localhost:5001`  | `5001`         |
| **Frontend (Nginx static site)** | `localhost:30080` | `80`           |
| **Kubernetes API Server**        | `localhost:6443`  | `6443`         |

> ⚠️ These only apply when running via Kubernetes, not Docker Compose.

---

## Next Steps and Future Improvements

- **Use Helm charts**: Package the manifests for easier configuration  
- **Add end-to-end tests**: Use Jenkins to verify backend behavior via HTTP  
- **Persist data across cluster deletion**: Use a `hostPath` in `persistent-volume.yaml`  
- **Add authentication**: Protect the backend API with a token or key  
- **Use GitHub Actions**: Replace Jenkins with a cloud-based CI/CD pipeline
