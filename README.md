# CRED rewards on Kubernetes — a pod that is genuinely Ready

Two endpoints that answer two different questions:

- `GET /healthz` — **is the process alive.** True from the first instant.
- `GET /readyz` — **can it serve.** False until the cache has warmed for `WARMUP_SECONDS`
  (default 5), then true.
- `GET /rewards` — the actual work. Answers 503 until ready.

## How to make /readyz fail on purpose

    BREAK_READINESS=1 python3 app/server.py
    curl -i localhost:8080/healthz   # 200 — the process is fine
    curl -i localhost:8080/readyz    # 503, for ever

That is the shape of a deploy that starts and never serves, which is exactly the case a
readiness probe exists to catch and a liveness probe does not.

## How to get a local cluster running

`kind` runs Kubernetes inside Docker and needs nothing else:

    brew install kind kubectl
    kind create cluster --name dz0
    kubectl cluster-info

To let the cluster use an image you built locally, load it rather than pushing:

    docker build -t cred-rewards:0.1.0 .
    kind load docker-image cred-rewards:0.1.0 --name dz0

⚠️ A locally built image is **not** pullable by the cluster unless you load it or push it to a
registry. A pod stuck in `ImagePullBackOff` with a local-looking tag is almost always this.

## Run it without Kubernetes first

    python3 app/server.py
    curl -i localhost:8080/readyz   # 503 for the first 5 seconds, then 200
