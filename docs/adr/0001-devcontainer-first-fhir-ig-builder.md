# ADR-0001: Modernize FHIR IG Builder with Devcontainer and SUSHI 3.x

**Status:** Proposed  
**Date:** 2026-07-22  
**Deciders:** Eric Friday, MatchSync team  

## Context

The existing `fhir-ig-builder` repository (by Jason Brelsford) is a monolithic Docker image that bundles Node.js, JDK 17, Ruby/Jekyll, Apache/PHP, and SUSHI into a single container intended for interactive use. It has several problems:

1. **Outdated tooling** — Uses unversioned `FROM node` base image with globally-installed SUSHI (version unspecified)
2. **No FSH source** — Contains only a default `sushi-config.yaml` template with no actual profiles or extensions
3. **Inappropriate hosting** — Bundles Apache/PHP for local preview, which is unnecessary with modern IG Publisher
4. **No CI/CD** — GitHub Action only builds the Docker image, doesn't validate FSH or build the IG
5. **Interactive-only** — Requires `docker run -it` and manual commands inside the container
6. **No devcontainer support** — Doesn't integrate with VS Code or other devcontainer-aware editors

Meanwhile, the FHIR community has established clear modern patterns:
- **bonfhir/ig-toolbox** — Docker image with SUSHI + GoFSH + IG Publisher + CLI tools
- **cybernop/vscode-fhir-devcontainer** — Pre-built devcontainer images up to SUSHI 3.14.0
- **FHIR/ig-guidance** — The canonical IG project structure with `_genonce.sh`, `_updatePublisher.sh`, `ig.ini`

NMDP has multiple teams building IGs (CIBMTR Reporting, IDM, Donor API) with no shared template or conventions.

## Decision

Replace the monolithic Docker image with a **devcontainer-first** development environment using:

1. **Base image**: Pre-built devcontainer image with SUSHI 3.x, JDK, Ruby/Jekyll (either bonfhir/ig-toolbox or custom Dockerfile based on cybernop pattern)
2. **Project structure**: Follow FHIR/ig-guidance canonical layout with `input/fsh/`, `sushi-config.yaml`, `ig.ini`
3. **CI pipeline**: GitHub Actions that run SUSHI validation + IG Publisher build on PRs
4. **No bundled web server**: IG Publisher outputs static HTML; preview via `python -m http.server` or IG Publisher's built-in server
5. **NMDP conventions baked in**: Shared `aliases.fsh` with NMDP system URIs, extension namespaces, and standard dependencies

## Consequences

### Positive
- Teams can start authoring FSH immediately with zero local setup (just open in VS Code with devcontainer)
- CI catches profile errors before merge
- Shared template ensures consistent namespace usage across NMDP IGs
- SUSHI version is pinned and reproducible
- Aligns with HL7 community tooling (same scripts as HL7 IGs)

### Negative
- Existing Dockerfile is completely replaced (not incremental)
- Teams currently using the old image need to migrate (but there's no evidence anyone is actively using it)
- Devcontainer approach requires Docker Desktop or a remote container host

### Risks
- SUSHI 3.x may have breaking changes from whatever version was globally installed before (mitigated: no FSH source exists to break)
- bonfhir/ig-toolbox has only 2 GitHub stars and 12 commits — low community adoption (mitigated: we can pin to a specific tag or build our own image from the same pattern)

## Alternatives Considered

1. **Patch the existing Dockerfile** — Pin versions, remove Apache/PHP, add FSH source directory. Rejected because the fundamental design (monolithic interactive container) is wrong for modern IG development.

2. **Use Firely Terminal / Simplifier.net** — Commercial tooling that provides IG authoring, validation, and publishing. Rejected because it adds vendor lock-in and cost; the open-source SUSHI + IG Publisher toolchain is the HL7 standard.

3. **No Docker at all — local install** — Have developers install SUSHI, Java, Ruby locally. Rejected because it creates "works on my machine" problems and makes onboarding painful.
