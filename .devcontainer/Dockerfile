# syntax=docker/dockerfile:1
# NMDP FHIR IG Builder — devcontainer image
# Pre-warms: Node 22, pnpm, SUSHI, JDK 17, IG Publisher JAR

FROM mcr.microsoft.com/devcontainers/javascript-node:22

# Install JDK 17 (headless — only need runtime for IG Publisher)
RUN apt-get update \
    && apt-get install -y --no-install-recommends openjdk-17-jdk-headless \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable corepack so pnpm is available at the pinned version
RUN corepack enable

# Set up working directory
WORKDIR /workspaces/fhir-ig-builder

# Copy dependency manifests and install as root (node_modules stays in image)
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    corepack install \
    && pnpm install --frozen-lockfile

# Verify sushi is functional (no full compile)
RUN pnpm sushi --help > /dev/null 2>&1

# Download the latest IG Publisher JAR into input-cache/
RUN mkdir -p input-cache \
    && curl -fsSL -o input-cache/publisher.jar \
       https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar

# Set JVM memory limit for IG Publisher
ENV JAVA_TOOL_OPTIONS="-Xmx4g"

# Run as non-root node user
USER node
