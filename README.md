
# DevNotes — Containerized Full-Stack Notes App

DevNotes is a solo, self-contained project demonstrating how to containerize a simple full-stack application, deploy it to a local Kubernetes cluster (kind), manage state with a PersistentVolumeClaim, with a Jenkins job that builds and deploys everything on-demand.
<br/><br/>
This README covers the project’s purpose, architecture, and setup steps.

## Table of Contents
- [Project Purpose](#project-purpose)
- [System Overview](#system-overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
  - [Docker Compose](#option-1-docker-compose)
  - [Kubernetes with kind](#option-2-kubernetes-with-kind)
  - [Jenkins CI/CD](#option-3-jenkins-cicd)
- [Jenkins in Docker First-Time Setup](#jenkins-in-docker-first-time-setup)
- [Fixed Ports](#kubernetes-fixed-ports)
- [Next Steps and Future Improvements](#next-steps-and-future-improvements)

---

## Project Purpose

DevNotes aims to:

- Illustrate how to package a backend and frontend into separate Docker images.
- Show how to spin up a multi-service application using Kubernetes (kind) manifests.
- Demonstrate data persistence via a PVC that survives pod restarts (but not cluster deletion).
- Provide a reference CI/CD pipeline (Jenkins) for building images and deploying to kind.

The actual “notes” app is trivial (create/read simple text entries), as the focus is on the container/cluster setup. 

---

## System Overview

### Components
1. **The DevNotes App**
   - A fullstack app for note-taking. Made of:
   - **Backend**, located in `backend/`
     - A small Flask app that handles GET and POST requests for notes. 
     - It stores data in a local `notes.json` file.
   - **Frontend**, Located in `frontend/`
     - A static HTML page served with Nginx. It lets users submit new notes and view existing ones by calling the backend API.


2. **Docker Compose**
   - `docker-compose.yml` (root of repo)
   - Spins up both services and mounts a volume to preserve note data between runs.
   - Unused if you're using Kubernetes, but super convenient for local development and definitely the way to go for a simple setup.


3. **Kubernetes (kind)**
   - The app runs inside a local Kubernetes cluster using kind, emulating a production-like environment.
   - All YAML manifests live under `k8s/`.
     - `backend-deployment.yaml`, `backend-service.yaml` – deploy + expose the BE's Flask API.
     - `frontend-deployment.yaml`, `frontend-service.yaml` – deploy + expose the FE.
     - `persistent-volume.yaml` – defines a Persistent Volume (PV) inside the kind node.
     - `persistent-volume-claim.yaml` – claims that PV for the backend.
     - `ingress.yaml` - allows to access the different apps within the cluster with a clean, unified address instead of multiple ports.
     - `kind-config.yaml` – allows us to access the container using fixed ports.


5. **(Optional) Jenkins CI/CD**
   - simple CI pipeline that automates building Docker images and deploying them to the cluster.
   - Lives under `jenkins/` and in the `Jenkinsfile` (root of repo).

---

## Prerequisites

To run this project, make sure you have the following installed on your machine:

- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** (includes Docker CLI + Docker Engine)
- **[kubectl](https://kubernetes.io/docs/tasks/tools/)** (Kubernetes command-line tool)
- **[kind](https://kind.sigs.k8s.io/)** (to run a Kubernetes cluster locally using Docker)

If you're using macOS and have [Homebrew](https://brew.sh/), you can install most of these with:
```bash
brew install docker kubectl kind git
```


### Jenkins Installation (for CI/CD automation):
- **[Jenkins](https://www.jenkins.io/)** – installed manually or via Docker Compose  
- Alternatively, just use the provided `jenkins/docker-compose.yml` to run Jenkins locally.<br/>
If using this, also refer to [Jenkins in Docker First-Time Setup](#jenkins-in-docker-first-time-setup).

---

## Usage

How to start, use, and stop the project using Docker Compose, Kubernetes (kind), or Jenkins.


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

### Option 2: Kubernetes with kind

**Start everything:**
Starting Kubernetes manually has several steps, including starting the cluster, building & loading the docker images, and applying the manifests in-order.<br/>
I've created a script to do all of that, refer to it for the specific commands.
```bash
./bootstrap-kind.sh
```

**Use the app:**
- Frontend: [http://localhost:30080](http://localhost:30080)
- Backend is called internally from the frontend

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
- Go to [http://localhost:8081](http://localhost:8081)

**Run the pipeline:**
- Create a classic job using the `Jenkinsfile` at the root of the repo
- Run the job to build, load, and deploy everything to kind

**Use the app (after the job runs):**
- Visit: [http://localhost:30080](http://localhost:30080)

**Stop Jenkins:**
```bash
cd jenkins
docker-compose down
```

---

## Jenkins in Docker first-time setup

Jenkins in Docker requires some specific setup when running the cluster locally.<br/>

We need to supply Jenkins with an edited version of the Kubernetes config file `~/.kube/config`.
This is required because the address `127.0.0.1` is used, which wouldn't work when ran from inside the Jenkins container. 

We'll create a `kubeconfig.patched` file, that replaces `127.0.0.1` with `host.docker.internal`.

From inside the project folder run:
```bash
kubectl config view --raw --minify --context=kind-devnotes \
  | sed 's|https://127.0.0.1:|https://host.docker.internal:|; s|https://0.0.0.0:|https://host.docker.internal:|' \
  > ./jenkins/kubeconfig.patched
```

Note: If Jenkins has TLS authentication issues, you can skip it by editing `kubeconfig.patched` and replacing the `certificate-authority-data` line with `insecure-skip-tls-verify: true`.

---

## Kubernetes Fixed Ports

Below is a summary of all host↔container port mappings when using kubernetes. You can edit these in `k8s/kind-config.yaml`.

| Purpose                          | Host Address            | Container Port |
|----------------------------------|-------------------------|----------------|
| **Backend (Flask API)**          | `localhost:5001`        | `5001`         |
| **Frontend (nginx static site)** | `localhost:30080`       | `80`           |
| **Kubernetes API Server**        | `localhost:6443`        | `6443`         |

---

## Next Steps and Future Improvements

- **Use Helm charts**: Package the Kubernetes manifests as a Helm chart for parameterized deployments.
- **Implement end-to-end tests**: Add a test stage in Jenkins that inserts a note via the API, fetches it, and verifies the correct JSON response.
- **Persist data across cluster deletion**: Modify `persistent-volume.yaml` to use a `hostPath` that points to a local folder.
- **Add basic authentication**: Secure the backend endpoints with a token or API key, and configure the frontend to send it.
- **Add GitHub Actions**: Replace Jenkins with a GitHub Actions workflow to build images and deploy to kind. A little more fitting for a simple setup.
