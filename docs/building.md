## Building and setting up serverless endpoints

Just for keeping notes on how to build and deploy

Building docker image:
```bash
# Build the docker image
docker build -t atumn/runpod-wan:${tag} .
# or add --platform linux/amd64 on macOS
docker build --platform linux/amd64 --tag atumn/runpod-wan:${tag} .

# to push image
docker push atumn/runpod-wan:${tag}
```

for downloading files from output dir using `scp` or `noglob scp` if on mac:
```
scp -i ~/.ssh/id_ed25519 -P 22157 root@194.68.245.14:/workspace/comfywan/output/* ~/dev/ttt
```

# in case if you're running from pod, make sure to configure python to use python3.10
```bash
apt-get update && apt-get install -y --no-install-recommends \
   python3.10 python3.10-dev python3.10-distutils python3-pip aria2 \
   && ln -sf /usr/bin/python3.10 /usr/bin/python \
   && ln -sf /usr/bin/python3.10 /usr/bin/python3 \
   && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 \
   && ln -sf /usr/local/bin/pip /usr/bin/pip \
   && ln -sf /usr/local/bin/pip /usr/bin/pip3 
```