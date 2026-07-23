# ADR-0004: Drop Jekyll from Development Environment

**Status:** Proposed  
**Date:** 2026-07-22  
**Deciders:** Eric Friday, MatchSync team  

## Context

The original `fhir-ig-builder` Docker image installs Ruby, gem dependencies, Jekyll, and Bundler (~200MB of tooling). This was required because the FHIR IG Publisher historically delegated HTML page rendering to Jekyll — the Publisher would generate intermediate Liquid templates, then invoke Jekyll to produce the final HTML site.

Starting in late 2022, the IG Publisher introduced an **internal rendering engine** that replaces Jekyll entirely. As of IG Publisher version 1.3.x (2023+), Jekyll is no longer invoked during IG builds. The `-no-jekyll` flag is now the default behavior. The IG Publisher's changelog explicitly states: "Jekyll is no longer used or required."

Despite this, NMDP developers may still assume Jekyll is required because:
1. The existing `fhir-ig-builder` Dockerfile installs it
2. Older HL7 documentation (pre-2023) references Jekyll setup
3. Some community devcontainer images (cybernop) still include it for backward compatibility with very old Publisher versions
4. Internal NMDP documentation hasn't been updated to reflect this change

## Decision

**Remove Jekyll (Ruby, gems, Bundler) entirely** from the development environment. The devcontainer, CI pipeline, and all documentation will assume a Jekyll-free toolchain.

The pinned IG Publisher version (specified in `ig.ini`) will be a modern version that uses its internal rendering engine. No Ruby runtime will be required anywhere in the toolchain.

## Consequences

### Positive

- **~200MB smaller devcontainer image** — Ruby + gems + native extensions are a significant chunk of image size
- **Faster container builds** — `gem install` is slow and occasionally fails on native extension compilation
- **Eliminates a class of failures** — no more "gem version conflict" or "bundler can't find compatible versions" errors
- **Simpler dependency surface** — the toolchain is now Node.js + Java only (plus pnpm for package management)
- **Fewer security updates** — Ruby gems are an additional CVE surface that no longer needs monitoring
- **Aligns with HL7 community direction** — the Publisher team has moved away from Jekyll; new IGs should not depend on it

### Negative

- **Cannot use IG Publisher versions prior to ~1.3.0** — if a team needs to build with a very old Publisher for compatibility testing, they'd need to add Jekyll back. This is unlikely for any new IG.
- **Existing internal documentation references Jekyll** — teams reading old setup guides may be confused (mitigated: this ADR and the developer docs explain the change)

### Risks

- If the IG Publisher ever reintroduces a Jekyll dependency for a specific feature (extremely unlikely given the trajectory)

## Alternatives Considered

1. **Keep Jekyll "just in case"** — Adds 200MB and a fragile dependency for zero benefit with modern Publisher versions. Rejected because it actively misleads developers into thinking it's needed.

2. **Make Jekyll optional via devcontainer feature** — Allow developers to add it if they need it. Considered but unnecessary — any team that genuinely needs an ancient Publisher version can install Ruby themselves. The template should represent the modern path.
