# jenkins/Dockerfile
FROM jenkins/jenkins:lts

USER root

# Install the docker CLI
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*

# Let the 'jenkins' user access the docker socket
RUN usermod -aG docker jenkins

USER jenkins
