# Install ComfyUI on your Network Volume

1. [Create a RunPod Account](https://runpod.io).
2. Create a [RunPod Network Volume](https://www.runpod.io/console/user/storage).
3. Attach the Network Volume to a Secure Cloud [GPU pod](https://www.runpod.io/console/gpu-secure-cloud).
4. Select the RunPod Pytorch 2 template.
5. Deploy the GPU Cloud pod.
6. Once the pod is up, open a Terminal and install the required dependencies.

## Installation

1. Install the ComfyUI:
```bash
# Clone the repo
cd /workspace
git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git comfywan

# Upgrade Python
apt update
apt -y upgrade
apt-get install aria2 # for downloading models

# Ensure Python version is 3.10.12
python -V

# Create and activate venv
cd comfywan
python -m venv /workspace/venv
source /workspace/venv/bin/activate

# Install Torch 
pip install --no-cache-dir torch==2.7.0+cu128 --index-url https://download.pytorch.org/whl/cu128 --no-deps
pip install --no-cache-dir torchvision==0.22.0+cu128 torchaudio==2.7.0 --index-url https://download.pytorch.org/whl/cu128

# Install ComfyUI
pip install -r requirements.txt

# Installing ComfyUI Manager
git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager
cd custom_nodes/ComfyUI-Manager
pip install -r requirements.txt

# Installing KJNodes
git clone https://github.com/kijai/ComfyUI-KJNodes.git custom_nodes/ComfyUI-KJNodes
cd custom_nodes/ComfyUI-KJNodes
pip install -r requirements.txt

git clone https://github.com/welltop-cn/ComfyUI-TeaCache.git custom_nodes/ComfyUI-TeaCache
cd custom_nodes/ComfyUI-TeaCache
pip install -r requirements.txt
```
2. Install the Serverless dependencies:
```bash
pip install requests runpod==1.7.9 websocket-client
pip install onnxruntime-gpu
pip install triton
pip install mutagen

# Install SageAttention after ensuring the correct torch version
# wget -O https://github.com/atumn/runpod-wan/raw/refs/heads/main/sageattention-2.1.1-cp310-cp310-linux_x86_64.whl
# RUN pip install /tmp/sageattention-2.1.1-cp310-cp310-linux_x86_64.whl
git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention 
python setup.py install  # or pip install -e .

```
3. Download models:
```bash
# WAN2.2 I2V Q5_M
aria2c -x16 -s16 -d /workspace/models/diffusion_models -o wan2.2_i2v_high_noise_14B_Q5_K_M.gguf --continue=true https://huggingface.co/bullerwins/Wan2.2-I2V-A14B-GGUF/resolve/main/wan2.2_i2v_high_noise_14B_Q5_K_M.gguf
aria2c -x16 -s16 -d /workspace/models/diffusion_models -o wan2.2_i2v_low_noise_14B_Q5_K_M.gguf --continue=true https://huggingface.co/bullerwins/Wan2.2-I2V-A14B-GGUF/resolve/main/wan2.2_i2v_low_noise_14B_Q5_K_M.gguf

# WAN2.2 T2V Q5_M
aria2c -x16 -s16 -d /workspace/models/diffusion_models -o wan2.2_t2v_high_noise_14B_Q5_K_M.gguf --continue=true https://huggingface.co/bullerwins/Wan2.2-T2V-A14B-GGUF/resolve/main/wan2.2_t2v_high_noise_14B_Q5_K_M.gguf
aria2c -x16 -s16 -d /workspace/models/diffusion_models -o wan2.2_t2v_low_noise_14B_Q5_K_M.gguf --continue=true https://huggingface.co/bullerwins/Wan2.2-T2V-A14B-GGUF/resolve/main/wan2.2_t2v_low_noise_14B_Q5_K_M.gguf

# Download text encoders also GGUF
aria2c -x16 -s16 -d /workspace/models/text_encoders -o umt5-xxl-encoder-Q8_0.gguf --continue=true https://huggingface.co/city96/umt5-xxl-encoder-gguf/resolve/main/umt5-xxl-encoder-Q8_0.gguf

aria2c -x16 -s16 -d /workspace/models/text_encoders -o umt5_xxl_fp8_e4m3fn_scaled.safetensors --continue=true https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors

# Create CLIP vision directory and download models
aria2c -x16 -s16 -d /workspace/models/clip_vision -o clip_vision_h.safetensors --continue=true https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors

# Download VAE
aria2c -x16 -s16 -d /workspace/models/vae -o wan_2.1_vae_.safetensors --continue=true https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors

# see loras.md for LORAs
```

6. Create logs directory:
```bash
mkdir -p /workspace/logs
```