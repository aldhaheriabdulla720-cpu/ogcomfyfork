# Use multi-stage build with caching optimizations
# FROM nvidia/cuda:12.8.1-devel-ubuntu22.04
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

# Consolidated environment variables
ENV DEBIAN_FRONTEND=noninteractive \
   PIP_PREFER_BINARY=1 \
   PYTHONUNBUFFERED=1 \
   CMAKE_BUILD_PARALLEL_LEVEL=8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /

# Install Python 3.10 specifically and make it the default
RUN apt-get update && apt-get install -y --no-install-recommends \
   python3.10 python3.10-dev python3.10-distutils python3-pip python3.10-venv \
   curl ffmpeg ninja-build git git-lfs wget aria2 vim libgl1 libglib2.0-0 build-essential gcc \
   && ln -sf /usr/bin/python3.10 /usr/bin/python \
   && ln -sf /usr/bin/python3.10 /usr/bin/python3 \
   && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 \
   && ln -sf /usr/local/bin/pip /usr/bin/pip \
   && ln -sf /usr/local/bin/pip /usr/bin/pip3 \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*

# Verify Python version
RUN python --version && pip --version

# install runpod and requests for python
RUN pip install runpod requests websocket-client

# Add RunPod Handler and Docker container start script
COPY start.sh rp_handler.py ./

COPY comfy-manager-set-mode.sh /usr/local/bin/comfy-manager-set-mode
RUN chmod +x /usr/local/bin/comfy-manager-set-mode

RUN chmod +x /start.sh
ENTRYPOINT /start.sh
