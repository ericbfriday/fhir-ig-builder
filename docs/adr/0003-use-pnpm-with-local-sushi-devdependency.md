# ADR-0003: Use pnpm with Local SUSHI devDependency

**Status:** Proposed  
**Date:** 2026-07-22  
**Deciders:** Eric Friday, MatchSync team  

## Context

The HL7 FHIR community's documented approach for using SUSHI is a global install via `npm install -g fsh-sushi`. This means:

1. **No version pinning per-project** — developers and CI may run different SUSHI versions, producing different output
2. **"Works on my machine" drift** — one developer updates globally, another doesn't; subtle differences appear
3. **No script ergonomics** — without a `package.json`, there's no `npm run sushi` or equivalent; developers must remember CLI incantations
4. **The IG Publisher's fallback** — when the Java-based IG Publisher detects `.fsh` files, it shells out to find SUSHI via `sushi -v` (PATH lookup) or falls back to `npx fsh-sushi` (downloads latest on the fly)

Meanwhile, modern Node.js projects pin tooling as local devDependencies. This ensures every developer, CI runner, and container uses the exact same tool version determined by the lockfile.

NMDP developers strongly prefer pnpm over npm for its speed, strictness (no phantom dependencies), and disk efficiency (content-addressable store). The MatchSync team already uses pnpm + Volta across other repositories.

## Decision

This template repository uses **pnpm** as its package manager with `fsh-sushi` declared as a **local devDependency** in `package.json`.

### Implementation details

1. **`package.json`** at the project root with:
   - `"devDependencies": { "fsh-sushi": "^3.20.0" }`
   - `"packageManager": "pnpm@<pinned-version>"` (corepack support)
   - `"volta": { "node": "22.x.x", "pnpm": "<pinned-version>" }` (Volta support)
   - `"engines": { "node": ">=22" }`
   - Scripts: `sushi`, `build`, `watch`, `validate`, `publisher:update`
   - Informational `postinstall` message about FHIR package download

2. **Version pinning via two mechanisms** (covers all developer environments):
   - **Volta** — for developers with Volta installed (auto-switches Node and pnpm on `cd`)
   - **Corepack** — for devcontainer and CI (Node.js built-in, reads `packageManager` field)

3. **`pnpm-lock.yaml`** committed to the repository for reproducible installs.

4. **pnpm scripts as primary DX**:
   - `pnpm sushi` — compile FSH to JSON (fast, sub-second after first run)
   - `pnpm build` — compile FSH then run IG Publisher with `-no-sushi` flag
   - `pnpm watch` — SUSHI watch mode for iterative authoring

5. **HL7 canonical scripts kept as fallback** — `_genonce.sh`, `_gencontinuous.sh`, `_updatePublisher.sh` remain for ecosystem compatibility and for developers who prefer the traditional HL7 workflow. These scripts are not modified; the IG Publisher's own SUSHI detection (PATH → npx fallback) works because `npx` resolves from local `node_modules/.bin/`.

### Why pnpm over yarn or bun

- **pnpm** — fastest installs, strictest dependency resolution (no phantom deps), Volta support (experimental but functional with `VOLTA_FEATURE_PNPM=1`), corepack-native
- **yarn 4** — PnP mode can break tools that expect `node_modules/`; steeper learning curve for occasional contributors
- **bun** — Volta doesn't support Bun at all; less proven in CI; potential module resolution edge cases
- **npm** — slower installs, flat `node_modules/` allows phantom dependencies, no meaningful advantage for this use case

## Consequences

### Positive

- Every developer, CI runner, and devcontainer uses the exact same SUSHI version (lockfile-determined)
- `pnpm install` is fast (~2-5 seconds); lockfile ensures deterministic resolution
- `pnpm sushi` is more discoverable than remembering `sushi build .`
- Watch mode (`pnpm watch`) enables rapid FSH iteration without full IG Publisher overhead
- No conflict with the IG Publisher's internal SUSHI detection — `npx` resolves local installs first
- The `package.json` provides a natural home for other tooling scripts (publisher update, validate, etc.)

### Negative

- Adds `package.json` + `pnpm-lock.yaml` to the repo — unusual for HL7 community IGs (but standard for any Node.js project)
- Developers unfamiliar with pnpm need 30 seconds of orientation (mitigated: corepack auto-installs the right version)
- Volta's pnpm support is experimental (mitigated: corepack is the fallback for non-Volta environments)
- Creates a two-registry mental model: npm packages (via pnpm) + FHIR packages (via SUSHI's internal `fhir-package-loader`)

### Risks

- If SUSHI ever requires a specific npm-only post-install behavior that pnpm handles differently (unlikely — SUSHI is a standard TypeScript CLI with no native addons)
- Volta pnpm feature flag could be removed or changed (mitigated: corepack is the standard-track alternative)

## Alternatives Considered

1. **Global install via npm (HL7 community standard)** — No version pinning, no script ergonomics, works-on-my-machine drift. Rejected because reproducibility is a core requirement for a template repo that multiple teams will fork.

2. **npx/pnpm dlx on every invocation (no install at all)** — Downloads SUSHI fresh each time or uses a cache. Rejected because it's slower (first-run penalty on every CI job) and doesn't provide lockfile-based pinning.

3. **Bundled in devcontainer only** — Install SUSHI globally inside the container image. Rejected because it doesn't help local-without-container development, and the devcontainer approach still benefits from a lockfile (pinned version survives image rebuilds).
