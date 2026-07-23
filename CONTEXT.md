# CONTEXT.md — NMDP FHIR IG Builder

## What this project is

A template repository and development environment for authoring FHIR Implementation Guides at NMDP using FHIR Shorthand (FSH) and SUSHI. It provides a reproducible toolchain (devcontainer + CI) so teams can focus on defining profiles and extensions rather than wrestling with Java/Ruby/Node dependencies.

## Who uses it

- **MatchSync team** — building the FHIR Donor API IG (donor profiles, HLA observations, order ServiceRequests)
- **Genomic Services (Gene) team** — building the IDM FHIR IG (infectious disease marker profiles)
- **CIBMTR/Enterprise FHIR team** — maintaining the CIBMTR Reporting IG (transplant data reporting)
- Any NMDP team that needs to publish FHIR conformance resources

## Domain overview

NMDP (National Marrow Donor Program / Be The Match) operates the world's largest registry of potential hematopoietic cell donors. The clinical domain involves:

1. **Donor registration and typing** — labs submit HLA typing data via HML messages, which are converted to FHIR and stored in AWS HealthLake
2. **Donor search and matching** — transplant centers search for matching donors using HLA compatibility algorithms
3. **Order coordination** — transplant centers place orders for confirmatory typing (CT), infectious disease marker (IDM) testing, and collection
4. **Data reporting** — transplant outcomes are reported to CIBMTR via FHIR-based APIs

The FHIR IGs codify the data contracts for these interactions.

## Canonical URLs and namespaces

| Namespace | Base URL | Purpose |
| --------- | -------- | ------- |
| NMDP IG profiles | `http://fhir.nmdp.org/StructureDefinition/` | StructureDefinitions for profiles and extensions |
| NMDP terminology | `http://terminology.nmdp.org/` | Identifiers and code systems |
| CIBMTR terminology | `http://terminology.cibmtr.org/` | CIBMTR-specific identifiers and code systems |
| ISBT128 (GRID) | `http://www.isbt128.org/uri/GRID` | Global donor identifier |
| NMDP IG canonical | `http://fhir.nmdp.org/ig/<ig-name>/` | IG publication URL |

## Key IGs at NMDP

| IG | Canonical | Status | Description |
| -- | --------- | ------ | ----------- |
| CIBMTR Reporting | `http://fhir.nmdp.org/ig/cibmtr-reporting` | v0.1.11 (STU) | HCT data reporting; US Core + mCODE based |
| FHIR Donor API | TBD | Draft | Donor demographics, HLA, orders for TC consumers |
| IDM FHIR IG | TBD | Draft | Infectious disease marker lab results on HealthLake |
| MatchSync Patient Import | `http://fhir.nmdp.org/ig/matchsync` | Published (PDF) | Patient import guide for EHR integration |

## Technology stack (target state)

- **FSH source** in `input/fsh/` — profiles, extensions, value sets, examples
- **SUSHI 3.x** — compiles FSH to FHIR JSON; installed as a local devDependency via pnpm (see ADR-0003)
- **pnpm** — package manager for Node.js tooling; pinned via corepack (`packageManager` field) and Volta
- **Node.js 22** — runtime for SUSHI; pinned via Volta and `engines` field
- **IG Publisher** (Java JAR) — builds the complete IG HTML site using internal renderer (no Jekyll); version pinned in `ig.ini`
- **JDK 17+** — required by the IG Publisher
- **Devcontainer** — reproducible dev environment (Node 22 + JDK 17 + corepack/pnpm; no Ruby/Jekyll)
- **GitHub Actions** — CI pipeline that validates FSH and builds IG (errors block, warnings inform)
- **FHIR R4** (4.0.1) — the FHIR version all NMDP IGs target
- **FHIR dependencies**: US Core 6.x, HL7 Genomics Reporting, mCODE (as needed per IG) — managed via `sushi-config.yaml`, downloaded from `packages.fhir.org`

## FHIR infrastructure at NMDP

```
┌──────────────────────────────────────────────────────────────┐
│  Data Sources                                                │
├──────────────┬───────────────┬───────────────┬───────────────┤
│ HML Messages │ HL7 ORU Feeds │ Manual Entry  │ Direct FHIR   │
│  (Labs)      │  (Labs)       │    (FN3)      │  (TC EHRs)    │
└──────┬───────┴───────┬───────┴───────┬───────┴───────┬───────┘
       │               │               │               │
       v               v               v               v
┌──────────────────────────────────────────────────────────────┐
│  Transformation Layer                                        │
│  HML Gateway │ HL7→FHIR │ FN3→FHIR │ (passthrough)          │
└──────────────────────────────────┬───────────────────────────┘
                                   │
                                   v
┌──────────────────────────────────────────────────────────────┐
│  FHIR Data Store: AWS HealthLake                             │
│  SMART-on-FHIR auth (Okta) │ Multi-tenant │ FHIR R4         │
└──────────────────────────────────┬───────────────────────────┘
                                   │
                                   v
┌──────────────────────────────────────────────────────────────┐
│  Consumer APIs                                               │
│  CIBMTR Direct FHIR │ FHIR Donor API │ IDM Orchestration    │
└──────────────────────────────────────────────────────────────┘
```

## Project structure (target)

```
/
├── CONTEXT.md                     # This file
├── UBIQUITOUS_LANGUAGE.md         # Domain glossary
├── docs/adr/                      # Architecture Decision Records
├── sushi-config.yaml              # IG metadata and SUSHI configuration
├── ig.ini                         # IG Publisher bootstrap config
├── input/
│   ├── fsh/
│   │   ├── profiles/              # StructureDefinitions (*.fsh)
│   │   ├── extensions/            # Extension definitions (*.fsh)
│   │   ├── valuesets/             # ValueSet definitions (*.fsh)
│   │   ├── codesystems/           # CodeSystem definitions (*.fsh)
│   │   ├── examples/              # Example instances (*.fsh)
│   │   └── aliases.fsh            # Shared aliases for URLs/codes
│   ├── pagecontent/               # Narrative markdown pages
│   └── images/                    # Diagrams and figures
├── .devcontainer/
│   └── devcontainer.json          # Devcontainer spec for reproducible env
├── .github/workflows/
│   ├── build-ig.yml               # CI: validate FSH + build IG
│   └── publish-ig.yml             # CD: publish to fhir.nmdp.org
├── _updatePublisher.sh            # Downloads IG Publisher JAR
├── _genonce.sh                    # Single build run
└── _gencontinuous.sh              # Watch mode for iterative authoring
```

## Design decisions

See `docs/adr/` for formal records. Key decisions:

1. **Devcontainer-first development** — No local toolchain setup required; all dependencies in container image
2. **FSH as source of truth** — All profiles/extensions/value sets authored in FSH, not hand-written JSON/XML
3. **FHIR R4 only** — No STU3 support in this template (CIBMTR STU3 guide is legacy)
4. **Shared NMDP patterns** — Identifier systems, extension namespaces, and terminology URLs follow AGNIS-on-FHIR conventions
5. **GitHub Actions CI** — Validate on every PR; publish on merge to main
