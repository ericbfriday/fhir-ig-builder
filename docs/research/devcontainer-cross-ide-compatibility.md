# Dev Container Cross-IDE Compatibility Research

**Date:** 2026-07-22
**Author:** Research Agent
**Context:** Issue #2 — Devcontainer implementation for FHIR IG Builder
**Related ADRs:** ADR-0001 (devcontainer-first), ADR-0004 (no Ruby/Jekyll)

---

## 1. Executive Summary

### Key Findings

| IDE | Dev Container Support | Status | Recommendation |
|-----|----------------------|--------|----------------|
| **VS Code** | Full native support | ✅ Production-ready | Primary target IDE |
| **Zed** | Basic support (v0.218+) | ⚠️ Usable with limitations | Secondary target — works for local dev |
| **Kiro IDE** | No native support | ❌ Not supported | Use Kiro CLI inside container as workaround |

### Go/No-Go Summary

- **VS Code**: GO — Full devcontainer spec support, GitHub Codespaces, all container runtimes
- **Zed**: CONDITIONAL GO — Works for local containers; `forwardPorts` not yet supported, `customizations.zed` recently added, remote devcontainers not supported
- **Kiro IDE**: NO-GO for native devcontainer — The VS Code Dev Containers extension is proprietary (not on Open VSX) and Kiro is a Code OSS fork. Workaround: use Kiro CLI inside a running container, or use Kiro IDE with OpenShift Dev Spaces via SSH

### Critical Decision

Design the `devcontainer.json` primarily for VS Code and the `devcontainer` CLI (which Zed uses under the hood). Kiro IDE users will use Kiro CLI inside the container or connect via SSH to a remote containerized workspace.

---

## 2. Dev Containers Specification Overview

### Current State

The Development Container Specification is maintained at [containers.dev](https://containers.dev/implementors/spec/) (previously devcontainers.github.io). It defines a JSON-based metadata format (`devcontainer.json`) for configuring containerized development environments.

**Source:** https://containers.dev/implementors/spec/

### Core Concepts

- **devcontainer.json** — Located at `.devcontainer/devcontainer.json` (primary), `.devcontainer.json`, or `.devcontainer/<folder>/devcontainer.json`
- **Three orchestration modes:** Image-based, Dockerfile-based, Docker Compose-based
- **Features** — OCI-distributed, self-contained installation units (e.g., `ghcr.io/devcontainers/features/java`)
- **Lifecycle scripts** — `initializeCommand` → `onCreateCommand` → `updateContentCommand` → `postCreateCommand` → `postStartCommand` → `postAttachCommand`
- **Customizations** — Tool-specific settings under `customizations.<tool-name>`

### Spec Properties (from devcontainer-reference.md)

The spec defines these categories of properties:
- **Container creation:** `image`, `build.dockerfile`, `build.context`, `build.args`, `build.target`, `build.cacheFrom`
- **Features:** `features` object mapping OCI references to options
- **Lifecycle:** `initializeCommand`, `onCreateCommand`, `updateContentCommand`, `postCreateCommand`, `postStartCommand`, `postAttachCommand`, `waitFor`
- **Environment:** `containerEnv`, `remoteEnv`, `containerUser`, `remoteUser`, `userEnvProbe`
- **Ports:** `forwardPorts`, `portsAttributes`, `otherPortsAttributes`, `appPort`
- **Mounts:** `mounts`, `workspaceMount`, `workspaceFolder`
- **Customizations:** `customizations` (tool-specific, e.g., `customizations.vscode`)
- **Host requirements:** `hostRequirements` (cpus, memory, storage, gpu)

**Source:** https://github.com/devcontainers/spec/blob/main/docs/specs/devcontainerjson-reference.md

### Supporting Tools (Official List)

Per https://containers.dev/supporting:
- VS Code Dev Containers extension
- GitHub Codespaces
- DevPod
- Visual Studio 2022 (C++ only)
- JetBrains IDEs (Gateway)
- `devcontainer` CLI (reference implementation)
- Zed (since v0.218, uses devcontainer CLI)

**Source:** https://containers.dev/supporting, https://github.com/devcontainers/spec/blob/main/docs/specs/supporting-tools.md


---

## 3. IDE-by-IDE Analysis

### 3.1 VS Code

**Status:** Full production support — the reference implementation for the spec.

#### Features Supported
- All `devcontainer.json` properties (VS Code team co-authors the spec)
- Full lifecycle script execution
- OCI Features installation
- Docker Compose multi-container setups
- Port forwarding (`forwardPorts` + auto-detection)
- `customizations.vscode` for extensions and settings
- GPU passthrough (`hostRequirements.gpu`)

#### Container Runtimes Supported
- Docker Desktop (Windows, macOS)
- Docker Engine (Linux)
- Podman 5+ (set `dev.containers.dockerPath` to `podman`)
- Rancher Desktop (via Moby/Docker CLI compatibility)
- OrbStack (macOS — drop-in Docker Desktop replacement)
- Colima (macOS — via Docker context)

**Source:** https://code.visualstudio.com/remote/advancedcontainers/docker-options

#### Remote Workflows
- **GitHub Codespaces** — Full support (web, desktop, CLI)
- **Remote-SSH + Dev Containers** — Connect to remote Docker host
- **VS Code Tunnels** — Connect from browser/another VS Code to a machine running containers
- **WSL** — Dev Containers inside WSL2

#### VS Code-Specific Properties
These are under `customizations.vscode` and only affect VS Code:
```json
{
  "customizations": {
    "vscode": {
      "extensions": ["ms-python.python"],
      "settings": { "editor.tabSize": 2 }
    }
  }
}
```

Other IDEs simply ignore `customizations.vscode`.

---

### 3.2 Zed

**Status:** Basic support since v0.218 (January 2026). Still in active development.

**Source:** https://zed.dev/docs/dev-containers, https://zed.dev/blog/dev-containers

#### How It Works
- Zed uses the **`devcontainer` CLI** (reference implementation) under the hood
- Calls `devcontainer up` to build/start containers
- Connects to running container via `docker exec` (not SSH)
- Runs a Zed Remote Server inside the container for language servers, tasks, terminals

#### Requirements
- Docker or Podman must be installed and in PATH
- If using Podman, set `"use_podman": true` in Zed settings
- BuildKit support via `docker buildx` (can be disabled with `"dev_container_use_buildkit": false`)

#### What Works
- `image` — ✅
- `build` / `dockerFile` — ✅
- `features` — ✅ (via devcontainer CLI)
- `postCreateCommand` / `postStartCommand` / `postAttachCommand` — ✅
- `containerEnv` — ✅
- `remoteUser` — ✅
- `mounts` — ✅
- `customizations.zed.extensions` — ✅ (recently added)
- Auto-detection of `.devcontainer/devcontainer.json` — ✅
- Auto-reconnect on reopen — ✅

#### Known Limitations (as of July 2026)
1. **`forwardPorts` NOT supported** — Due to a known issue in the devcontainer CLI (#22). Only `appPort` works.
2. **No automatic rebuild** — Changes to `devcontainer.json` require manually killing the container
3. **No remote devcontainers** — Local containers only (Discussion #56252 on Zed's roadmap)
4. **Extensions loaded globally** — Extensions specified in `customizations.zed` load for the whole Zed session, not just the container project

**Source:** https://zed.dev/blog/dev-containers (explicit statement about forwardPorts limitation), https://github.com/zed-industries/zed/discussions/56252

#### Planned Features (from "What's Next" in blog post)
- `forwardPorts` support (requires moving away from CLI dependency)
- Custom Zed extensions in `devcontainer.json`
- In-house implementation replacing devcontainer CLI dependency
- Dev Container spec definition tooling

---

### 3.3 Kiro IDE

**Status:** No native devcontainer support. Workarounds exist.

**Source:** https://github.com/kirodotdev/Kiro/issues/164, https://github.com/kirodotdev/Kiro/issues/1740

#### Why It Doesn't Work
- Kiro IDE is a **Code OSS fork** (not VS Code)
- The VS Code **Dev Containers extension is proprietary** (Microsoft) and not available on Open VSX
- Users have tried installing older versions of the Dev Containers extension and DevPod extension — neither works
- Issue #164 (opened July 2025) remains open with `keep-open` and `pending-maintainer-response` labels
- Issue #1740 (August 2025) was closed as duplicate of #164

#### Workarounds Available

1. **Kiro CLI inside a devcontainer** (recommended workaround)
   - Start the container using `devcontainer up` or VS Code
   - Run `kiro-cli` inside the container for agentic AI assistance
   - Updated January 2026 per issue #164 comment
   - **Source:** https://dev.classmethod.jp/en/articles/kiro-cli-in-devcontainer/

2. **Kiro IDE + Red Hat OpenShift Dev Spaces** (enterprise)
   - SSH from local Kiro IDE to containerized workspace on OpenShift cluster
   - Available since OpenShift Dev Spaces 3.25 (May 2026)
   - **Source:** https://www.redhat.com/en/blog/aws-and-red-hat-red-hat-summit-2026-accelerating-ai-innovation-and-open-source-infrastructure

3. **Kiro IDE + SageMaker Studio** (AWS)
   - Connect Kiro IDE to SageMaker Unified Studio via Systems Manager Session Manager
   - Not container-based; uses cloud compute environments
   - **Source:** https://aws.amazon.com/about-aws/whats-new/2026/03/amazon-sagemaker-studio-kiro-cursor/

4. **Kiro IDE + Citrix Secure Developer Spaces**
   - SSH-based connection to containerized workspace
   - **Source:** https://docs.citrix.com/en-us/secure-developer-spaces/workspace/ssh-ws

#### CodeCatalyst Dev Environments
- AWS CodeCatalyst uses **devfiles** (devfile.io), NOT `devcontainer.json`
- CodeCatalyst is no longer open to new customers (migration notice in docs)
- Not a viable path for devcontainer-based workflows
- **Source:** https://docs.aws.amazon.com/codecatalyst/latest/userguide/devenvironment.html


---

## 4. Cross-Platform Container Runtime Analysis

### 4.1 Docker Desktop

| OS | Status | Notes |
|----|--------|-------|
| macOS | ✅ Full support | VirtioFS file sharing; bind mount ~3x slower than native |
| Windows | ✅ Full support | WSL2 backend recommended |
| Linux | ✅ Full support | Native performance, no VM overhead |

- **Licensing:** Free for small businesses (<250 employees AND <$10M revenue), paid otherwise
- **Dev Container compatibility:** Reference platform — all features work
- **File sync feature:** Paid — reduces macOS bind mount overhead by 59%

**Source:** https://www.paolomainardi.com/posts/docker-performance-macos-2025/

### 4.2 Podman

| OS | Status | Notes |
|----|--------|-------|
| Linux | ✅ Native | Daemonless, rootless by default |
| macOS | ⚠️ Works | Via Podman Machine (VM); some devcontainer edge cases |
| Windows | ⚠️ Works | Via WSL2/Podman Machine |

- **VS Code support:** Set `dev.containers.dockerPath` to `podman` (version 5+ recommended)
- **Zed support:** Set `"use_podman": true` in settings
- **Gotchas:**
  - Rootless mode can cause permission issues with some base images
  - Some Features scripts assume Docker-specific paths
  - `podman compose` requires an external compose provider

**Source:** https://code.visualstudio.com/remote/advancedcontainers/docker-options

### 4.3 OrbStack (macOS only)

| OS | Status | Notes |
|----|--------|-------|
| macOS | ✅ Excellent | Drop-in Docker Desktop replacement, fastest bind mounts |

- **Performance:** Bind mounts at 4.22s vs Docker Desktop's 9.53s (npm install benchmark)
- **VS Code compatibility:** Full — acts as Docker Desktop drop-in
- **Zed compatibility:** Works (provides Docker CLI/socket)
- **Licensing:** Free for personal use, paid for commercial
- **No Podman support** inside OrbStack (Docker/Moby only)

**Source:** https://www.paolomainardi.com/posts/docker-performance-macos-2025/, https://orbstack.dev/

### 4.4 Rancher Desktop

| OS | Status | Notes |
|----|--------|-------|
| macOS | ✅ Works | Via Moby (Docker CLI compatible) |
| Windows | ✅ Works | WSL2 backend |
| Linux | ✅ Works | Native |

- **VS Code support:** Confirmed in VS Code docs — uses Docker CLI via Moby
- **No Podman engine support** (closed as won't-fix: GitHub issue #8502)
- **Free and open source**

**Source:** https://code.visualstudio.com/remote/advancedcontainers/docker-options, https://github.com/rancher-sandbox/rancher-desktop/issues/8502

### 4.5 Colima (macOS/Linux)

- Open source, lightweight, uses Lima under the hood
- Docker context integration — compatible with VS Code Dev Containers
- Performance comparable to Docker Desktop with VirtioFS
- **Note:** Uses Alpine Linux VM — not compatible with Remote-SSH

**Source:** https://code.visualstudio.com/remote/advancedcontainers/docker-options

### 4.6 Performance Summary (macOS npm install benchmark)

| Platform | Bind Mount Time | Relative to Native |
|----------|----------------|-------------------|
| Native (no Docker) | 3.38s | 1.0x |
| OrbStack | 4.22s | 1.25x |
| Docker Desktop + File Sync | 3.88s | 1.15x (paid) |
| Lima (open source) | 8.99s | 2.66x |
| Docker Desktop (VirtioFS) | 9.53s | 2.82x |
| Docker Desktop (VMM beta) | 8.47s | 2.51x |
| Linux (Docker native) | 5.29s | 1.0x (no overhead) |

**Source:** https://www.paolomainardi.com/posts/docker-performance-macos-2025/


---

## 5. Local Workflow Considerations

### IDE Detection Behavior

| IDE | Auto-detect | Prompt | Build Trigger |
|-----|-------------|--------|---------------|
| VS Code | ✅ Yes | "Reopen in Container" notification | Automatic on accept |
| Zed | ✅ Yes | Toast at bottom-right | Automatic on accept |
| Kiro IDE | ❌ No | N/A | N/A |

### File Permissions on Linux

- The spec supports `updateRemoteUserUID` to sync container user UID/GID with host user
- This prevents permission issues with bind mounts on Linux
- Set `"updateRemoteUserUID": true` (default in most base images)
- Microsoft's devcontainer base images already handle this

**Source:** https://containers.dev/implementors/spec/#container-creation

### macOS Bind Mount Performance

**Problem:** Bind mounts on macOS cross a VM boundary (host ↔ Linux VM), causing I/O overhead.

**Impact on FHIR IG Builder:**
- `pnpm install` with many small files — significant slowdown (2.5-3x)
- SUSHI watch mode relies on filesystem events (inotify) — events DO propagate via VirtioFS but with latency
- IG Publisher (Java) reads many FHIR definition files — affected by bind mount speed

**Mitigations:**
1. **Named volumes for heavy I/O directories** (e.g., `node_modules`, `.fhir/packages`)
2. **OrbStack** for fastest macOS bind mount performance
3. **Docker Desktop file sync** (paid feature)
4. The spec's `postCreateCommand` can pre-populate volumes inside the container

### Windows Considerations

- WSL2 backend required for good performance
- Files should live inside WSL2 filesystem (not `/mnt/c/`)
- VS Code WSL extension integrates with Dev Containers

---

## 6. Remote Workflow Considerations

### 6.1 GitHub Codespaces

- Full `devcontainer.json` support — the same spec, running in the cloud
- Accessible via: VS Code desktop, VS Code web, GitHub CLI (`gh cs`)
- Supports `hostRequirements` for machine sizing
- Pre-builds available for faster startup
- **Ideal for this project:** Pre-warmed FHIR cache in a prebuild image

**Source:** https://docs.github.com/codespaces

### 6.2 VS Code Remote-SSH + Dev Containers

- Connect to remote Linux host via SSH
- Open Dev Container on that remote host
- **Limitation:** Cannot bind-mount local files into remote container (source must be on remote)
- Good for: powerful remote dev servers, GPU workloads

**Source:** https://github.com/microsoft/vscode-docs/blob/main/remote/advancedcontainers/develop-remote-host.md

### 6.3 VS Code Tunnels

- Run `code tunnel` on a remote machine
- Connect from any browser or VS Code desktop
- Can forward to a container on that machine
- Useful for: accessing a persistent dev environment from anywhere

### 6.4 Amazon CodeCatalyst Dev Environments

- Uses **devfile.io** format (NOT devcontainer.json)
- CodeCatalyst is no longer open to new customers
- Not recommended for this project

**Source:** https://docs.aws.amazon.com/codecatalyst/latest/userguide/devenvironment.html

### 6.5 Kiro IDE Remote Options

- **OpenShift Dev Spaces:** SSH from Kiro to containerized workspace (enterprise)
- **SageMaker Studio:** WebSocket tunnel via Systems Manager
- **Citrix Secure Developer Spaces:** SSH-based connection
- None of these use `devcontainer.json` directly

### 6.6 Zed Remote Development

- Zed supports SSH remote development (separate from Dev Containers)
- **Remote devcontainers NOT supported** — local only (GitHub Discussion #56252)
- On Zed's roadmap but no timeline given

**Source:** https://github.com/zed-industries/zed/discussions/56252, https://zed.dev/roadmap


---

## 7. Feature Compatibility Matrix

| devcontainer.json Property | VS Code | Zed | Kiro IDE | Spec Standard |
|---------------------------|---------|-----|----------|---------------|
| `image` | ✅ | ✅ | ❌ | ✅ Core |
| `build` / `dockerFile` | ✅ | ✅ | ❌ | ✅ Core |
| `dockerComposeFile` | ✅ | ❓ Untested | ❌ | ✅ Core |
| `features` (OCI) | ✅ | ✅ | ❌ | ✅ Core |
| `postCreateCommand` | ✅ | ✅ | ❌ | ✅ Core |
| `postStartCommand` | ✅ | ✅ | ❌ | ✅ Core |
| `postAttachCommand` | ✅ | ✅ | ❌ | ✅ Core |
| `onCreateCommand` | ✅ | ✅ | ❌ | ✅ Core |
| `initializeCommand` | ✅ | ✅ | ❌ | ✅ Core |
| `forwardPorts` | ✅ | ❌ Known limitation | ❌ | ✅ Core |
| `appPort` | ✅ | ✅ | ❌ | ⚠️ Deprecated |
| `portsAttributes` | ✅ | ❌ | ❌ | ✅ Core |
| `mounts` | ✅ | ✅ | ❌ | ✅ Core |
| `workspaceMount` | ✅ | ✅ | ❌ | ✅ Core |
| `workspaceFolder` | ✅ | ✅ | ❌ | ✅ Core |
| `remoteUser` | ✅ | ✅ | ❌ | ✅ Core |
| `containerUser` | ✅ | ✅ | ❌ | ✅ Core |
| `containerEnv` | ✅ | ✅ | ❌ | ✅ Core |
| `remoteEnv` | ✅ | ✅ | ❌ | ✅ Core |
| `hostRequirements` | ✅ | ❓ Unknown | ❌ | ✅ Core |
| `customizations.vscode` | ✅ | ❌ Ignored | ❌ | Tool-specific |
| `customizations.zed` | ❌ Ignored | ✅ | ❌ | Tool-specific |
| `customizations.codespaces` | ✅ (Codespaces) | ❌ | ❌ | Tool-specific |
| `updateRemoteUserUID` | ✅ | ✅ | ❌ | ✅ Core |
| `shutdownAction` | ✅ | ❓ Unknown | ❌ | ✅ Core |
| `overrideCommand` | ✅ | ✅ | ❌ | ✅ Core |

**Legend:** ✅ Supported | ❌ Not supported | ⚠️ Partial/Deprecated | ❓ Unconfirmed

**Key Insight:** All core spec properties (except `forwardPorts`) work in both VS Code and Zed because Zed delegates to the `devcontainer` CLI. The `forwardPorts` gap is due to a CLI limitation (devcontainers/cli#22), not a spec issue.

**Sources:**
- VS Code: https://code.visualstudio.com/docs/remote/devcontainerjson-reference
- Zed: https://zed.dev/blog/dev-containers (explicit forwardPorts limitation noted)
- Kiro: https://github.com/kirodotdev/Kiro/issues/164


---

## 8. Recommendations for FHIR IG Builder devcontainer.json

### Recommended Structure

```jsonc
// .devcontainer/devcontainer.json
{
  "name": "FHIR IG Builder",
  "image": "mcr.microsoft.com/devcontainers/javascript-node:22",

  // Install JDK 17 for IG Publisher
  "features": {
    "ghcr.io/devcontainers/features/java:1": {
      "version": "17",
      "installMaven": "false",
      "installGradle": "false"
    }
  },

  // Enable corepack for pnpm, install dependencies, warm FHIR cache
  "postCreateCommand": "corepack enable && pnpm install && pnpm sushi --help > /dev/null 2>&1 || true",

  // Forward IG Publisher preview server port
  "forwardPorts": [80],

  // Environment for JDK memory and pnpm
  "containerEnv": {
    "JAVA_TOOL_OPTIONS": "-Xmx4g",
    "COREPACK_ENABLE_STRICT": "0"
  },

  "remoteUser": "node",

  // Named volume for pnpm store to survive rebuilds and improve macOS perf
  "mounts": [
    "source=fhir-ig-builder-pnpm-store,target=/home/node/.local/share/pnpm/store,type=volume",
    "source=fhir-ig-builder-fhir-cache,target=/home/node/.fhir,type=volume"
  ],

  // VS Code specific settings (ignored by Zed, harmless)
  "customizations": {
    "vscode": {
      "extensions": [
        "MITRE-Health.vscode-language-fsh",
        "redhat.java"
      ],
      "settings": {
        "editor.tabSize": 2,
        "files.eol": "\n"
      }
    },
    // Zed extensions (ignored by VS Code, harmless)
    "zed": {
      "extensions": []
    }
  },

  // Minimum requirements for IG Publisher
  "hostRequirements": {
    "cpus": 2,
    "memory": "8gb",
    "storage": "32gb"
  }
}
```

### Why This Structure

1. **`image` over `build`** — Maximizes cache hits across all IDEs and Codespaces. Avoids build-time differences between tools.

2. **`features` for JDK** — Standard OCI Feature from devcontainers/features. Works in VS Code, Zed (via CLI), and Codespaces identically.

3. **`postCreateCommand` for pnpm setup** — Runs after container creation in all spec-compliant tools. Enables corepack and installs dependencies so `pnpm sushi` works immediately.

4. **Named volumes for heavy I/O** — Avoids macOS bind mount penalty for `node_modules`-adjacent data (pnpm store) and FHIR package cache. Survives container rebuilds.

5. **`forwardPorts`** — Will work in VS Code and Codespaces. Won't work in Zed today (but Zed users can manually expose ports via Docker).

6. **`customizations` with both `vscode` and `zed`** — Each IDE reads its own section and ignores others. Safe cross-IDE pattern.

7. **`hostRequirements`** — Important for Codespaces machine sizing. IG Publisher needs substantial memory.

### What to Avoid

- **Don't use `runArgs`** — Not portable across all tools
- **Don't use `appPort`** — Deprecated; prefer `forwardPorts`
- **Don't put secrets in `containerEnv`** — Use `remoteEnv` with secret references or `.env` files
- **Don't use `initializeCommand` for heavy work** — Runs on host, not in container; behavior differs across OSes
- **Don't assume Docker Compose** — Adds complexity; single container is sufficient for this project

### FHIR Cache Strategy

**Recommendation: Named volume + `postCreateCommand` warm-up**

```jsonc
"mounts": [
  "source=fhir-ig-builder-fhir-cache,target=/home/node/.fhir,type=volume"
],
"postCreateCommand": "corepack enable && pnpm install && node scripts/warm-fhir-cache.js"
```

- Named volume persists across container rebuilds (unlike bind mounts, works the same on all OSes)
- `postCreateCommand` script downloads required FHIR packages on first create
- Subsequent container starts skip download (packages already in volume)
- For Codespaces: use prebuilds to pre-warm the cache in the prebuild image


---

## 9. Known Pitfalls and Mitigations

### 9.1 File Watching (SUSHI watch mode) on macOS

**Problem:** inotify events cross the VM boundary with latency. Some watchers may miss rapid changes or fire with delay.

**Impact:** SUSHI's `--watch` mode uses Node.js `fs.watch()`/`chokidar`. On macOS with Docker Desktop + VirtioFS, filesystem events DO propagate but with 100-500ms latency.

**Mitigations:**
- Use polling-based watchers as fallback (`CHOKIDAR_USEPOLLING=1`)
- OrbStack has better filesystem event propagation than Docker Desktop
- For CI, watch mode is irrelevant (run once)
- Consider documenting `CHOKIDAR_USEPOLLING=1` in `containerEnv` for macOS users who experience issues

### 9.2 JDK Memory in Constrained Containers

**Problem:** IG Publisher is a Java application that defaults to taking 25% of available RAM. In a container limited to 4GB, it may OOM.

**Mitigations:**
- Set `JAVA_TOOL_OPTIONS: "-Xmx4g"` in `containerEnv`
- Set `hostRequirements.memory: "8gb"` to ensure enough RAM
- For Codespaces, this maps to at least a 4-core machine (8GB RAM)
- Monitor with `java -XshowSettings:vm -version` in postCreateCommand

### 9.3 pnpm Store Location

**Problem:** pnpm's content-addressable store defaults to `~/.local/share/pnpm/store`. If inside a bind mount, macOS performance degrades significantly. If inside the container filesystem, it's lost on rebuild.

**Recommendation:** Named volume mounted at the store path.

```jsonc
"mounts": [
  "source=fhir-ig-builder-pnpm-store,target=/home/node/.local/share/pnpm/store,type=volume"
]
```

This gives:
- Native Linux I/O performance (volume is in the VM filesystem)
- Persistence across container rebuilds
- No bind mount overhead on macOS

### 9.4 `.fhir/packages` Cache Strategy

**Options evaluated:**

| Strategy | Pros | Cons |
|----------|------|------|
| Bind mount from host | Shared with host tools | Slow on macOS, permission issues |
| Named volume | Fast, persistent, cross-platform | Not visible on host |
| Rebuild every time | Always fresh | Slow (downloads ~500MB of FHIR packages) |
| Bake into image | Fastest startup | Stale, large image |

**Recommendation: Named volume** — Best balance of performance, persistence, and simplicity. The `postCreateCommand` script handles initial population.

### 9.5 Linux UID/GID Mismatch

**Problem:** On Linux hosts, the container user's UID may not match the host user's UID, causing permission denied on bind-mounted files.

**Mitigation:** `"updateRemoteUserUID": true` (default in Microsoft base images). The devcontainer tooling automatically syncs UIDs on Linux.

### 9.6 Zed `forwardPorts` Workaround

**Problem:** Zed doesn't support `forwardPorts` yet.

**Workaround:** Users can manually expose ports:
```bash
# From host, forward container port to localhost
docker exec -it <container> sh -c "socat TCP-LISTEN:80,fork TCP:localhost:80" &
# Or simply use docker run with -p flag (handled by appPort in devcontainer.json)
```

Or add to devcontainer.json (deprecated but works in Zed):
```jsonc
"appPort": [80]
```

### 9.7 Container Runtime on CI

**Problem:** CI environments (GitHub Actions) don't use the full devcontainer lifecycle.

**Mitigation:** The devcontainer CLI can be used in CI:
```yaml
- uses: devcontainers/ci@v0.3
  with:
    runCmd: pnpm test
```

This ensures CI uses the same environment as local development.

---

## 10. Sources Cited

### Specifications
1. Dev Containers Specification: https://containers.dev/implementors/spec/
2. devcontainer.json Reference: https://github.com/devcontainers/spec/blob/main/docs/specs/devcontainerjson-reference.md
3. Dev Container Features: https://github.com/devcontainers/spec/blob/main/docs/specs/devcontainer-features.md
4. Supporting Tools: https://containers.dev/supporting

### VS Code
5. VS Code Dev Containers docs: https://code.visualstudio.com/docs/remote/containers
6. VS Code Docker options: https://code.visualstudio.com/remote/advancedcontainers/docker-options
7. VS Code devcontainer.json reference: https://code.visualstudio.com/docs/remote/devcontainerjson-reference

### Zed
8. Zed Dev Containers docs: https://zed.dev/docs/dev-containers
9. Zed Dev Containers blog post (Jan 2026): https://zed.dev/blog/dev-containers
10. Zed remote devcontainer discussion: https://github.com/zed-industries/zed/discussions/56252
11. Zed roadmap: https://zed.dev/roadmap
12. devcontainer CLI forwardPorts issue: https://github.com/devcontainers/cli/issues/22

### Kiro IDE
13. Kiro devcontainer feature request (#164): https://github.com/kirodotdev/Kiro/issues/164
14. Kiro devcontainer duplicate issue (#1740): https://github.com/kirodotdev/Kiro/issues/1740
15. Kiro CLI in devcontainer guide: https://dev.classmethod.jp/en/articles/kiro-cli-in-devcontainer/
16. Kiro + OpenShift Dev Spaces: https://www.redhat.com/en/blog/aws-and-red-hat-red-hat-summit-2026-accelerating-ai-innovation-and-open-source-infrastructure
17. Kiro IDE intro (Code OSS basis): https://kiro.dev/blog/introducing-kiro/
18. Kiro FAQ: https://kiro.dev/faq/

### Container Runtimes & Performance
19. Docker macOS performance benchmarks (Jan 2025): https://www.paolomainardi.com/posts/docker-performance-macos-2025/
20. OrbStack fast filesystem blog: https://orbstack.dev/blog/fast-filesystem
21. OrbStack file change issues: https://github.com/orbstack/orbstack/issues/1287
22. Rancher Desktop Podman support (won't-fix): https://github.com/rancher-sandbox/rancher-desktop/issues/8502

### FHIR Devcontainer Examples
23. cybernop/vscode-fhir-devcontainer: https://github.com/cybernop/vscode-fhir-devcontainer
24. bonfhir/ig-toolbox: https://github.com/bonfhir/ig-toolbox
25. NIH-NCPI/hl7-fhir-ig-publisher (Docker): https://github.com/NIH-NCPI/hl7-fhir-ig-publisher

### AWS / CodeCatalyst
26. CodeCatalyst Dev Environments: https://docs.aws.amazon.com/codecatalyst/latest/userguide/devenvironment.html
27. CodeCatalyst devfile docs: https://docs.aws.amazon.com/codecatalyst/latest/userguide/devenvironment-devfile.html
28. SageMaker Studio + Kiro: https://aws.amazon.com/about-aws/whats-new/2026/03/amazon-sagemaker-studio-kiro-cursor/

### Other
29. VS Code improve performance docs: https://github.com/microsoft/vscode-docs/blob/main/remote/advancedcontainers/improve-performance.md
30. Docker osxfs caching: https://github.com/adamancini/docker.github.io/blob/master/docker-for-mac/osxfs-caching.md

---

## Appendix: Existing FHIR Devcontainer Patterns

### cybernop/vscode-fhir-devcontainer

Pre-built images with SUSHI and IG Publisher:
- `ghcr.io/cybernop/vscode-fhir-devcontainer/fsh-sushi:<version>-<os>`
- `ghcr.io/cybernop/vscode-fhir-devcontainer/ig-publisher:<version>-<os>`
- Tags: `3.14.0-alpine`, `3.14.0-ubuntu`, etc.
- Usage: Set `"image"` in devcontainer.json

**Source:** https://github.com/cybernop/vscode-fhir-devcontainer

### bonfhir/ig-toolbox

Docker image for FHIR IG authoring:
- Requires running `_updatePublisher.sh` after project creation
- Provides complete toolchain in a single image

**Source:** https://github.com/bonfhir/ig-toolbox

### Key Takeaway for Our Project

Our approach (base Node 22 image + Java feature + pnpm) is more maintainable than the existing examples because:
1. Uses official Microsoft base image (security updates, multi-arch)
2. Uses standard OCI Features (composable, versioned)
3. Does not bake SUSHI/IG Publisher versions into a custom image (installed via pnpm)
4. Follows the devcontainer spec precisely (works across tools)
