#!/usr/bin/env bash

# Check if /runpod-volume exists
if [ -d "/runpod-volume" ]; then
  echo "Symlinking files from Network Volume"
  rm -rf /workspace && ln -s /runpod-volume /workspace
  source /workspace/venv/bin/activate
  echo "venv info:"
  echo $VIRTUAL_ENV && python -V && which python && which pip
  # Use libtcmalloc for better memory management
  TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
  export LD_PRELOAD="${TCMALLOC}"
  export PYTHONUNBUFFERED=true
  export HF_HOME="/workspace"
  
  cd /workspace/comfywan
  
  # Ensure ComfyUI-Manager runs in offline network mode inside the container
  comfy-manager-set-mode offline || echo "worker-comfyui - Could not set ComfyUI-Manager network_mode" >&2
  
  echo "worker-comfyui: Starting ComfyUI"
  # Allow operators to tweak verbosity; default is INFO.
  : "${COMFY_LOG_LEVEL:=INFO}"

  # python main.py --port 3000 --use-sage-attention > /workspace/logs/comfywan.log 2>&1 &
  # python main.py --use-sage-attention --listen 
  # make sure to use full path. otherwise the base will change to /runpod-volume
  python -u /workspace/comfywan/main.py --port 3000 --use-sage-attention --base-directory /workspace/comfywan --disable-auto-launch --disable-metadata --verbose "${COMFY_LOG_LEVEL}" --log-stdout &
  # deactivate

  echo "worker-comfyui: Starting RunPod Handler"
  python -u /rp_handler.py
else
  echo "Warning: /runpod-volume does not exist"
  exit 1
fi
