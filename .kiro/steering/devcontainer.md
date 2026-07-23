# Dev Container Workspace Context

## Overview

This project uses a devcontainer (`.devcontainer/devcontainer.json`) for reproducible development environments. When working inside the container, the environment has:

- Node.js 22 (with corepack enabled for pnpm)
- JDK 17 (for FHIR IG Publisher)
- pnpm with pre-installed dependencies
- FHIR package cache at `~/.fhir/packages/`

## Key Commands

- `pnpm sushi` — Compile FSH to FHIR resources
- `pnpm build` — Full IG Publisher build (requires JDK)
- `pnpm validate` — Run SUSHI validation only

## Container Runtimes

Developers may use any Docker-compatible runtime:
- Docker Desktop (Windows/macOS)
- OrbStack (macOS — fastest bind mounts)
- Podman 5+ (Linux — rootless)
- Rancher Desktop (all platforms)

## IDE Support Matrix

| IDE | Dev Container Support |
|-----|----------------------|
| VS Code | Full native support |
| Zed | Basic (local only, no forwardPorts) |
| Kiro IDE | Via VSIX sideload (see `scripts/setup-kiro-devcontainers.sh`) |

## Kiro CLI in Containers

Kiro CLI works natively inside devcontainers. The `.kiro/` directory at the repo root is mounted into the container workspace, providing:
- Steering files (this file)
- Skills
- MCP server configs
- LSP settings

No special configuration is needed — `kiro` commands work as-is inside the container.
