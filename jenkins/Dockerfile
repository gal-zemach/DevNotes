# jenkins/Dockerfile
FROM jenkins/jenkins:lts

USER root

# Install Docker CLI, containerd, kubectl, kind
RUN apt-get update && \
    apt-get install -y \
      docker.io \
      containerd \
      curl && \
    # install kubectl
    curl -Lo /usr/local/bin/kubectl \
      https://storage.googleapis.com/kubernetes-release/release/$(curl -s \
        https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    # install kind
    curl -Lo /usr/local/bin/kind \
      https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 && \
    chmod +x /usr/local/bin/kind && \
    rm -rf /var/lib/apt/lists/*

# Let the 'jenkins' user access the docker socket
RUN usermod -aG docker jenkins

USER jenkins
