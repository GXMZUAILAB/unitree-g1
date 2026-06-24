# Dev Container Dockerfile — reuses the main training Dockerfile
# VS Code will build this automatically when you "Reopen in Container"
FROM g1-rl-train:latest

# Dev container specific additions: install git for VS Code Git integration
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
