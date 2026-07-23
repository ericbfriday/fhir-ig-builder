# Toolchain

This document explains the tools used to build FHIR Implementation Guides in this project and how they fit together.

---

## Overview

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 22.x | Runtime for SUSHI (FSH compiler) |
| pnpm | 10.x | Package manager — fast, strict, disk-efficient |
| SUSHI (fsh-sushi) | 3.x | Compiles FHIR Shorthand (.fsh) → FHIR JSON |
| IG Publisher | Latest | Builds the full IG website from FHIR resources |
| JDK | 17 | Required by IG Publisher (not needed for SUSHI alone) |

The devcontainer includes all of these pre-configured. If you're working locally without a container, see the [Getting Started guide](getting-started.md) for install instructions.

---

## pnpm Scripts vs HL7 Shell Scripts

This project provides two ways to build:

### pnpm scripts (recommended)

```bash
pnpm sushi          # Fast FSH compilation only
pnpm build          # SUSHI + full IG Publisher build
pnpm watch          # Re-compile on every .fsh file save
pnpm validate       # SUSHI + IG Publisher validation (no terminology server)
pnpm publisher:update  # Download latest IG Publisher JAR
```

These scripts are defined in `package.json` and use the **locally installed** SUSHI from `node_modules/`. This ensures every developer uses the exact same SUSHI version, determined by `pnpm-lock.yaml`.

### HL7 canonical shell scripts (fallback)

```bash
./_genonce.sh       # Download IG Publisher (if needed) + full build
./_gencontinuous.sh # Watch mode using IG Publisher's built-in watcher
./_updatePublisher.sh  # Download latest IG Publisher JAR
```

These are the standard scripts used across HL7 community IGs. They work by:
1. Downloading the IG Publisher JAR to `input-cache/`
2. Invoking SUSHI via PATH lookup (or `npx` fallback)
3. Running the full IG Publisher build

**When to use each:**

| Scenario | Use |
|----------|-----|
| Day-to-day FSH authoring | `pnpm sushi` or `pnpm watch` |
| Full IG build for review | `pnpm build` |
| CI pipeline | `pnpm build` (pinned versions) |
| Troubleshooting IG Publisher | `./_genonce.sh` (more verbose output) |
| Matching HL7 community workflows | Shell scripts |

See [ADR-0003](../adr/0003-use-pnpm-with-local-sushi-devdependency.md) for the rationale behind this dual approach.

---

## FHIR Package Caching

SUSHI downloads FHIR package dependencies (declared in `sushi-config.yaml`) on first run. These are cached locally so subsequent runs are fast.

### Where packages live

```
~/.fhir/packages/
├── hl7.fhir.r4.core#4.0.1/       # FHIR R4 base definitions
├── hl7.fhir.us.core#6.1.0/       # US Core profiles
└── ...
```

Inside the devcontainer, this directory is stored on a named Docker volume (`fhir-ig-builder-fhir-cache`) so it persists across container rebuilds.

### What triggers downloads

- Running `pnpm sushi` for the first time (resolves dependencies from `sushi-config.yaml`)
- Adding a new entry to the `dependencies` section of `sushi-config.yaml`
- Changing a dependency version

### How to clear the cache

```bash
# Remove all cached FHIR packages (forces re-download on next SUSHI run)
rm -rf ~/.fhir/packages/

# Inside a devcontainer, you can also remove the Docker volume:
docker volume rm fhir-ig-builder-fhir-cache
```

### Download sources

SUSHI resolves packages from these registries (in order):
1. **packages.fhir.org** — the primary FHIR package registry
2. **packages2.fhir.org** — mirror/fallback
3. **Local `~/.fhir/packages/`** — if already cached, no network request

---

## Dependency Management

### FHIR package dependencies

Declared in `sushi-config.yaml`:

```yaml
dependencies:
  hl7.fhir.us.core: 6.1.0
```

These are **FHIR packages** (not npm packages). They contain StructureDefinitions, ValueSets, and CodeSystems that your profiles can reference. Browse available packages at [packages.fhir.org](https://packages.fhir.org/).

To add a dependency:
1. Find the package on [packages.fhir.org](https://packages.fhir.org/)
2. Add it to `sushi-config.yaml` under `dependencies`
3. Run `pnpm sushi` — SUSHI downloads it automatically

### npm dependencies

Declared in `package.json`:

```json
{
  "devDependencies": {
    "fsh-sushi": "^3.13.0"
  }
}
```

Currently, `fsh-sushi` is the only npm dependency. It's declared as a devDependency so that:
- The lockfile pins the exact version
- `pnpm install` makes the `sushi` CLI available in `node_modules/.bin/`
- All pnpm scripts use this local version (not a global install)

---

## Version Pinning

This project uses multiple mechanisms to ensure reproducible builds across environments:

### Volta (local development)

[Volta](https://volta.sh/) automatically activates the correct Node.js and pnpm versions when you `cd` into the project. Versions are declared in `package.json`:

```json
{
  "volta": {
    "node": "22.21.1",
    "pnpm": "10.33.0"
  }
}
```

If you have Volta installed, it handles everything transparently. No manual version switching needed.

> **Note:** Volta's pnpm support is experimental. Enable it with `export VOLTA_FEATURE_PNPM=1`.

### Corepack (devcontainer and CI)

Node.js ships with [Corepack](https://nodejs.org/api/corepack.html), which reads the `packageManager` field:

```json
{
  "packageManager": "pnpm@10.33.0"
}
```

The devcontainer's `postCreateCommand` runs `corepack enable`, which activates pnpm at the pinned version. CI pipelines should do the same.

### SUSHI version (lockfile)

The exact SUSHI version is determined by `pnpm-lock.yaml`. Running `pnpm install` always produces the same `node_modules/` regardless of when or where it runs.

To update SUSHI:

```bash
pnpm update fsh-sushi
# Review changes, test with `pnpm sushi`, then commit the updated lockfile
```

### IG Publisher version

The IG Publisher JAR is downloaded to `input-cache/publisher.jar` by `_updatePublisher.sh` (or `pnpm publisher:update`). It's listed in `.gitignore` — each developer downloads it on demand. CI should run `pnpm publisher:update` before `pnpm build`.

To pin a specific IG Publisher version, edit the version URL in `_updatePublisher.sh`.

---

## How the Tools Connect

```
 ┌─────────────────────────────────────────────────────────────┐
 │  Developer writes .fsh files in input/fsh/                  │
 └──────────────────────────┬──────────────────────────────────┘
                            │
                            ▼
 ┌─────────────────────────────────────────────────────────────┐
 │  SUSHI (pnpm sushi)                                         │
 │  Reads: input/fsh/*.fsh + sushi-config.yaml                 │
 │  Writes: fsh-generated/resources/*.json                     │
 └──────────────────────────┬──────────────────────────────────┘
                            │
                            ▼
 ┌─────────────────────────────────────────────────────────────┐
 │  IG Publisher (pnpm build)                                  │
 │  Reads: fsh-generated/ + input/pagecontent/ + ig.ini        │
 │  Writes: output/ (full IG website — HTML, JSON, XML)        │
 └─────────────────────────────────────────────────────────────┘
```

For day-to-day FSH authoring, you only need SUSHI (`pnpm sushi` or `pnpm watch`). The full IG Publisher build is for generating the publishable IG website and running profile validation.
