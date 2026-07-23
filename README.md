# NMDP FHIR IG Builder

A devcontainer-first template for authoring FHIR Implementation Guides at NMDP using FHIR Shorthand (FSH) and SUSHI.

<!-- TODO: replace with actual badge URLs once CI is configured -->
![CI Status](https://img.shields.io/badge/CI-passing-brightgreen)
![License](https://img.shields.io/badge/license-Apache%202.0-blue)

---

## 60-Second Quick Start

### Prerequisites

- A Docker-compatible runtime: [Docker Desktop](https://www.docker.com/products/docker-desktop/), [OrbStack](https://orbstack.dev/), or [Podman 5+](https://podman.io/)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) (or [Kiro CLI](https://kiro.dev/docs/cli/))

### Steps

```bash
git clone https://github.com/ericbfriday/fhir-ig-builder.git
cd fhir-ig-builder

# Open in VS Code → "Reopen in Container" when prompted
# Or use Kiro CLI directly inside the container (see docs/dev/getting-started.md)

pnpm sushi
# Output: fsh-generated/ directory with compiled FHIR resources
```

First run downloads FHIR packages (~30 seconds). Subsequent runs are sub-second.

---

## Project Structure

```
fhir-ig-builder/
├── input/
│   ├── fsh/
│   │   ├── aliases.fsh        # Shared URL aliases for all FSH files
│   │   ├── profiles/          # FHIR profile definitions
│   │   ├── extensions/        # FHIR extension definitions
│   │   ├── valuesets/         # ValueSet definitions
│   │   ├── codesystems/       # CodeSystem definitions
│   │   └── examples/          # Example resource instances
│   └── pagecontent/           # Narrative pages for the IG website
├── fsh-generated/             # SUSHI output (git-ignored in real projects)
├── .devcontainer/             # Dev Container configuration
├── docs/
│   ├── dev/                   # Developer documentation
│   └── adr/                   # Architecture Decision Records
├── sushi-config.yaml          # IG metadata and FHIR dependencies
├── ig.ini                     # IG Publisher configuration
├── package.json               # pnpm scripts and toolchain pins
└── _genonce.sh                # HL7 canonical build script (fallback)
```

---

## Available Commands

| Command | Description |
|---------|-------------|
| `pnpm sushi` | Compile FSH to FHIR JSON resources |
| `pnpm build` | Full IG Publisher build (requires JDK 17) |
| `pnpm validate` | Run SUSHI + IG Publisher validation (no terminology server) |
| `pnpm watch` | Watch mode — recompiles FSH on every save |
| `pnpm publisher:update` | Download the latest IG Publisher JAR |

All commands are available inside the devcontainer. See [ADR-0003](docs/adr/0003-use-pnpm-with-local-sushi-devdependency.md) for why pnpm was chosen.

---

## IDE Support

| IDE | Dev Container | FSH Highlighting | Notes |
|-----|:---:|:---:|-------|
| VS Code | ✅ Full | ✅ | Native Dev Containers extension |
| Zed | ⚠️ Basic | ❌ | Local containers only, no `forwardPorts` |
| Kiro IDE | ✅ Full | ✅ | Requires VSIX sideload (see `scripts/setup-kiro-devcontainers.sh`) |
| Kiro CLI | ✅ Native | — | Works in any terminal, no extensions needed |

---

## Documentation

- **[Getting Started](docs/dev/getting-started.md)** — Full setup guide for every IDE and platform
- **[Toolchain](docs/dev/toolchain.md)** — Node, pnpm, SUSHI, IG Publisher, and dependency management
- **[Editor Setup](docs/dev/editor-setup.md)** — Extensions, settings, and per-IDE configuration
- **[Contributing](CONTRIBUTING.md)** — Branch workflow, commit conventions, and FSH style guide

### Architecture Decisions

- [ADR-0001: Devcontainer-first approach](docs/adr/0001-devcontainer-first-fhir-ig-builder.md)
- [ADR-0002: NMDP FHIR namespace conventions](docs/adr/0002-nmdp-fhir-namespace-conventions.md)
- [ADR-0003: pnpm with local SUSHI](docs/adr/0003-use-pnpm-with-local-sushi-devdependency.md)
- [ADR-0004: No Ruby/Jekyll](docs/adr/0004-drop-jekyll-from-development-environment.md)

---

## License

[Apache 2.0](LICENSE)

---

## Attribution

Original work by [Jason Brelsford](https://github.com/nmdp-ig/fhir-ig-builder). Modernized by the MatchSync team at NMDP.
