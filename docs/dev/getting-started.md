# Getting Started — FHIR IG Builder

This guide covers setting up a development environment for the NMDP FHIR Implementation Guide using **Kiro IDE** (our org's preferred AI harness), **Kiro CLI**, **VS Code**, or **Zed**.

---

## Quick Start (any IDE)

```bash
git clone https://github.com/ericbfriday/fhir-ig-builder.git
cd fhir-ig-builder
pnpm install
pnpm sushi       # Should produce 0 Errors, 0 Warnings
```

For the full containerized experience (recommended), read on.

---

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| Docker-compatible runtime | Dev Container | Docker Desktop, OrbStack, Podman 5+, or Rancher Desktop |
| Kiro IDE | IDE with AI agents | [kiro.dev/downloads](https://kiro.dev/downloads/) |
| Kiro CLI | Terminal AI assistant | [kiro.dev/docs/cli](https://kiro.dev/docs/cli/) |
| Node.js 22 | Local dev (without container) | Via [Volta](https://volta.sh/) — see `package.json` pins |
| pnpm | Package management | Enabled via corepack (`corepack enable`) |

---

## Option A: Kiro IDE + Dev Container (Recommended)

Kiro IDE is a Code OSS fork with built-in AI agents. The VS Code Dev Containers extension is proprietary but can be sideloaded.

### One-time setup

Run the setup script to download and install the Dev Containers extension:

```bash
./scripts/setup-kiro-devcontainers.sh
```

This script:
1. Downloads the `ms-vscode-remote.remote-containers` VSIX from the VS Code Marketplace
2. Installs it into Kiro IDE via `kiro --install-extension`
3. Configures `~/.kiro/argv.json` with the required `enable-proposed-api` entry

**Manual alternative** (if the script doesn't work for your platform):

1. Go to [VS Code Marketplace — Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Click **"Download Extension"** in the Resources sidebar (right side of page)
3. In Kiro IDE: `Ctrl+Shift+P` → **"Extensions: Install from VSIX..."** → select the downloaded `.vsix`
4. Open `~/.kiro/argv.json` (or `Ctrl+Shift+P` → **"Preferences: Configure Runtime Arguments"**):
   ```json
   {
     "enable-proposed-api": [
       "ms-vscode-remote.remote-containers"
     ]
   }
   ```
5. **Restart Kiro IDE completely** (close all windows, reopen)

### Open the project in a container

1. Open the `fhir-ig-builder` folder in Kiro IDE
2. You should see a toast: **"Reopen in Container"** — click it
3. If no toast appears: `Ctrl+Shift+P` → **"Dev Containers: Reopen in Container"**
4. First build takes ~2 minutes (downloads Node 22, JDK 17, installs pnpm deps)
5. Subsequent opens are instant (named volumes cache pnpm store and FHIR packages)

### Verify it works

```bash
# Inside the container terminal
pnpm sushi
# Expected: 0 Errors, 0 Warnings
```

### After Kiro IDE updates

Kiro IDE updates may break the sideloaded extension. If Dev Containers stops working:

```bash
# Re-run the setup script
./scripts/setup-kiro-devcontainers.sh
# Restart Kiro IDE
```

---

## Option B: Kiro CLI Inside the Container

Kiro CLI works natively inside devcontainers — no special setup needed. This is the **most reliable** Kiro workflow and doesn't require sideloading any extensions.

### Start the container (using `devcontainer` CLI)

```bash
# Install the devcontainer CLI (one-time)
npm install -g @devcontainers/cli

# Start the container
devcontainer up --workspace-folder .

# Open a shell inside
devcontainer exec --workspace-folder . bash
```

### Or start via Docker directly

```bash
# Build and run (uses the devcontainer.json config)
docker run -it \
  -v "$(pwd):/workspaces/fhir-ig-builder" \
  -w /workspaces/fhir-ig-builder \
  mcr.microsoft.com/devcontainers/javascript-node:22 \
  bash
```

### Use Kiro CLI inside the container

```bash
# If kiro-cli is installed on the host, it's available via mount
# Otherwise, install inside the container:
curl -fsSL https://kiro.dev/install.sh | bash

# Then use normally:
kiro chat
kiro chat "explain the SUSHI config"
kiro chat "add a Patient profile with NMDP donor identifiers"
```

### Kiro CLI project configuration

The `.kiro/` directory is mounted into the container automatically. It provides:

```
.kiro/
├── settings/
│   ├── lsp.json          # Language server configs (TypeScript, Java, etc.)
│   └── mcp.json          # MCP server configs (if any)
├── steering/
│   └── devcontainer.md   # Container-aware context for the AI agent
├── skills/               # Symlinked skill definitions
└── agents/               # Custom agent configs
```

No additional configuration is needed — Kiro CLI picks up the project config automatically.

---

## Option C: VS Code + Dev Container

VS Code has native Dev Container support. No sideloading needed.

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open the `fhir-ig-builder` folder
3. Click **"Reopen in Container"** when prompted
4. Done — all recommended extensions install automatically inside the container

---

## Option D: Zed + Dev Container

Zed supports devcontainers since v0.218 (January 2026). It uses the `devcontainer` CLI under the hood.

### Requirements

- Zed v0.218+
- Docker or Podman on PATH (for Podman: set `"use_podman": true` in Zed settings)

### Usage

1. Open the `fhir-ig-builder` folder in Zed
2. Zed auto-detects `.devcontainer/devcontainer.json`
3. Accept the toast to open in container

### Known limitations (as of July 2026)

- **`forwardPorts` not supported** — if you need to preview the IG locally, manually expose port 80:
  ```bash
  docker port <container-id>
  ```
- **No remote devcontainers** — local containers only
- **No auto-rebuild** — after changing `devcontainer.json`, manually kill the container and reopen

---

## Option E: Local Development (No Container)

If you prefer not to use containers:

### Requirements

- Node.js 22 (use [Volta](https://volta.sh/): `volta install node@22`)
- pnpm (`corepack enable`)
- JDK 17 (for full IG Publisher builds — SUSHI alone doesn't need it)

### Setup

```bash
git clone https://github.com/ericbfriday/fhir-ig-builder.git
cd fhir-ig-builder
pnpm install
pnpm sushi   # Validates FSH → FHIR
```

### Full IG Publisher Build (requires JDK 17)

```bash
./_genonce.sh     # Downloads IG Publisher JAR + builds the full IG
```

---

## GitHub Codespaces (Remote)

This repo's devcontainer works directly in GitHub Codespaces:

1. Go to the repo on GitHub
2. Click **Code** → **Codespaces** → **Create codespace on main**
3. Wait ~2 min for the environment to build
4. `pnpm sushi` works immediately in the terminal

Recommended machine type: **4-core** (8GB RAM minimum for IG Publisher).

---

## Kiro IDE Configuration Reference

### Workspace settings

The repo ships with Kiro CLI configuration at `.kiro/`:

| Path | Purpose |
|------|---------|
| `.kiro/settings/lsp.json` | Language servers (TypeScript, Java, Python, etc.) |
| `.kiro/settings/mcp.json` | MCP server connections (create if needed) |
| `.kiro/steering/devcontainer.md` | AI context about the container environment |
| `.kiro/skills/` | Available agent skills (symlinked from global) |

### Recommended Kiro IDE settings

Add to your Kiro IDE user settings (`Ctrl+Shift+P` → "Preferences: Open Settings (JSON)"):

```json
{
  "editor.tabSize": 2,
  "files.eol": "\n",
  "files.associations": {
    "*.fsh": "fsh"
  }
}
```

### argv.json for all remote extensions

If you use both WSL and Dev Containers with Kiro IDE, your `~/.kiro/argv.json` should include both:

```json
{
  "enable-proposed-api": [
    "ms-vscode-remote.remote-containers",
    "jeanp413.open-remote-wsl",
    "jeanp413.open-remote-ssh"
  ]
}
```

---

## Troubleshooting

### "Reopen in Container" doesn't appear in Kiro IDE

- Ensure you ran `./scripts/setup-kiro-devcontainers.sh`
- Check `~/.kiro/argv.json` has `ms-vscode-remote.remote-containers` in `enable-proposed-api`
- Restart Kiro IDE completely (all windows closed)
- Verify Docker is running: `docker info`

### Container build fails

- Ensure you have at least 8GB RAM allocated to Docker
- Check Docker disk space: `docker system df`
- Try a fresh build: `docker system prune` then reopen in container

### pnpm not found inside container

- The `postCreateCommand` enables corepack. If it failed:
  ```bash
  corepack enable
  pnpm install
  ```

### SUSHI downloads packages on every rebuild

- Named volumes persist FHIR cache across rebuilds. If they were pruned:
  ```bash
  docker volume create fhir-ig-builder-fhir-cache
  ```

### Kiro IDE extension breaks after update

- This is a known issue with sideloaded proprietary extensions
- Re-run `./scripts/setup-kiro-devcontainers.sh`
- Alternatively: use Kiro CLI inside the container (Option B) — it's update-proof

### macOS: Container is slow

- Switch from Docker Desktop to [OrbStack](https://orbstack.dev/) for 2-3x faster file I/O
- Named volumes (already configured) avoid the worst bind mount penalty
- If SUSHI watch mode misses changes, set `CHOKIDAR_USEPOLLING=1` in your terminal

### Windows: WSL2 recommended

- Use WSL2 backend for Docker Desktop
- Keep source files inside WSL2 filesystem (not `/mnt/c/`)
- See also: [Kiro IDE + WSL2 setup](https://github.com/rommelporras/kiro-config/blob/main/docs/setup/kiro-ide-wsl-setup.md)

---

## Further Reading

- [Dev Container cross-IDE compatibility research](../research/devcontainer-cross-ide-compatibility.md)
- [ADR-0001: Devcontainer-first approach](../adr/0001-devcontainer-first-fhir-ig-builder.md)
- [ADR-0004: No Ruby/Jekyll](../adr/0004-drop-jekyll-from-development-environment.md)
- [Kiro IDE docs](https://kiro.dev/docs/)
- [Kiro CLI docs](https://kiro.dev/docs/cli/)
- [Dev Containers spec](https://containers.dev/)
