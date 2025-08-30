#!/usr/bin/env bash
set -euo pipefail

echo "[boot] start.sh (ts=$(date -Is))"

VOL="/runpod-volume"

# -------------------------------
# 1) Ensure network volume exists
# -------------------------------
if [ ! -d "$VOL" ]; then
  echo "[vol] ERROR: $VOL does not exist. Attach your Network Volume at $VOL."
  exit 1
fi

# -------------------------------
# 2) Keep /workspace (code) intact
#    Only link data folders from volume
# -------------------------------
mkdir -p "$VOL/models" "$VOL/workflows" "$VOL/output" "$VOL/hf-cache"
mkdir -p /workspace/models /workspace/workflows /workspace/output

# Symlink data directories from volume (but leave /workspace intact)
ln -sfn "$VOL/models"     /workspace/models
ln -sfn "$VOL/workflows"  /workspace/workflows
ln -sfn "$VOL/output"     /workspace/output

# Hugging Face cache on volume
export HF_HOME="$VOL/hf-cache"
export TRANSFORMERS_CACHE="$HF_HOME"
export TORCH_HOME="$HF_HOME"

# -------------------------------
# 3) Optional venv (best effort)
# -------------------------------
if [ -f /workspace/venv/bin/activate ]; then
  # shellcheck disable=SC1091
  source /workspace/venv/bin/activate || true
else
  echo "[venv] /workspace/venv not found; using system Python."
fi

echo "venv info:"
python -V || true
command -v python || true
command -v pip || true

# Install missing runtime dep (avoids rebuild)
python - <<'PY' || pip install --no-cache-dir mutagen
try:
    import mutagen  # noqa
except Exception:
    raise SystemExit(1)
PY

# -------------------------------
# 4) Optional tcmalloc preload
# -------------------------------
if TCMALLOC="$(ldconfig -p 2>/dev/null | grep -Po 'libtcmalloc\.so\.\d' | head -n1)"; then
  export LD_PRELOAD="${TCMALLOC}"
fi
export PYTHONUNBUFFERED=1

# -------------------------------
# 5) Launch ComfyUI (code stays in image)
# -------------------------------
COMFY_HOST="${COMFY_HOST:-127.0.0.1}"
COMFY_PORT="${COMFY_PORT:-3000}"
COMFY_DIR="${COMFY_DIR:-/workspace/comfywan}"
COMFY_OUT="/workspace/output"

if [ ! -f "$COMFY_DIR/main.py" ]; then
  echo "[comfy] FATAL: $COMFY_DIR/main.py not found. Do NOT replace /workspace with the volume."
  exit 1
fi

# ComfyUI-Manager offline (non-fatal if absent)
comfy-manager-set-mode offline || echo "[comfy] manager offline set skipped."

echo "[comfy] starting at http://${COMFY_HOST}:${COMFY_PORT}"
# Avoid flags that aren't universally supported; keep yours minimal & stable
python -u "$COMFY_DIR/main.py" \
  --listen "$COMFY_HOST" \
  --port "$COMFY_PORT" \
  --output-directory "$COMFY_OUT" \
  --disable-auto-launch \
  > /tmp/comfyui.log 2>&1 &
COMFY_PID=$!

# Wait until Comfy is ready
for i in {1..180}; do
  if curl -sf "http://${COMFY_HOST}:${COMFY_PORT}/system_stats" >/dev/null; then
    echo "[comfy] ready."
    break
  fi
  if ! kill -0 "$COMFY_PID" 2>/dev/null; then
    echo "[comfy] exited early; last 200 lines:"
    tail -n 200 /tmp/comfyui.log || true
    exit 1
  fi
  sleep 1
done

# -------------------------------
# 6) Start RunPod serverless handler
# -------------------------------
echo "[runpod] starting serverless handler..."
exec python -m runpod.serverless
