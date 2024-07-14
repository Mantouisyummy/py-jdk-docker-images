# Use an official Ubuntu as a parent image
FROM ubuntu:22.04

ENV PYTHONUNBUFFERED=1

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/opt/java/openjdk

# Define build arguments
ARG PYTHON_VERSION
ARG OPENJDK_VERSION

ENV PYTHONPATH=/usr/local/lib/python${PYTHON_VERSION}

# Install dependencies and specified Python version
RUN apt-get update && \
    apt-get install -y software-properties-common wget gnupg && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev && \
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://packages.adoptium.net/artifactory/deb/ && \
    apt-get update && \
    apt-get install -y temurin-${OPENJDK_VERSION}-jdk && \
    ln -s /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python && \
    ln -s /opt/java/openjdk/bin /usr/local/bin && \
    ln -sf /usr/local/bin/pip${PYTHON_VERSION}  /usr/bin/pip3 \
    apt-get install -y curl ca-certificates openssl git tar bash sqlite3 fontconfig --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip using the specific python version
RUN pip3 install --upgrade setuptools
RUN pip3 install --upgrade pip
RUN pip3 --version

# Add a non-root user
RUN useradd -m -d /home/container -s /bin/bash container

# Switch to the non-root user
USER container
ENV USER=container HOME=/home/container

# Set working directory
WORKDIR /home/container

# Copy the entrypoint script
COPY ./entrypoint.sh /entrypoint.sh

# Set the entrypoint
CMD ["/bin/bash", "/entrypoint.sh"]
