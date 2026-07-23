# NMDP Identifier Systems

This page documents the identifier system URIs used across NMDP FHIR profiles. These systems are defined as FSH aliases in `aliases.fsh` and should be used consistently in all profiles within this IG and any IG derived from this template.

## Identifier System URIs

| FSH Alias | System URI | Description |
|-----------|-----------|-------------|
| `$nmdp-donor` | `http://terminology.nmdp.org/identifier/donor` | NMDP Donor ID — unique identifier assigned to each registered donor |
| `$nmdp-cbu` | `http://terminology.nmdp.org/identifier/cbu` | Cord Blood Unit ID — identifier for banked cord blood units |
| `$nmdp-recipient` | `http://terminology.nmdp.org/identifier/recipient` | Recipient ID — identifier for transplant recipients |
| `$nmdp-local-id` | `http://terminology.nmdp.org/identifier/local-id` | Center Local ID — facility-specific patient/donor identifier |
| `$nmdp-order` | `http://terminology.nmdp.org/identifier/order` | Order Number — identifier for service requests and orders |
| `$nmdp-hmlid` | `http://terminology.nmdp.org/identifier/hmlid` | HML Message ID — identifier for HML (Histoimmunogenetics Markup Language) messages |
| `$nmdp-specimen` | `http://terminology.nmdp.org/identifier/specimen` | Specimen ID — identifier for biological specimens |
| `$isbt-grid` | `http://www.isbt128.org/uri/GRID` | Global Registration Identifier for Donors (GRID) — internationally unique donor identifier per ISBT 128 |
| `$cibmtr-crid` | `http://terminology.cibmtr.org/identifier/CRID` | CIBMTR Research ID — research identifier assigned by the Center for International Blood and Marrow Transplant Research |

## Usage Convention

**Always use the FSH alias** when referencing identifier systems in profiles and examples. Never inline the full URL directly.

### Correct

```fsh
* identifier[donorId].system = $nmdp-donor
* identifier[donorId].value = "12345678"
```

### Incorrect

```fsh
// Do NOT do this — use the alias instead
* identifier[donorId].system = "http://terminology.nmdp.org/identifier/donor"
* identifier[donorId].value = "12345678"
```

All aliases are defined in `input/fsh/aliases.fsh`. If you need a new identifier system that is not yet listed, add it to `aliases.fsh` following the existing naming pattern (`$org-concept`).

## Design Rationale

The namespace and identifier conventions documented here are established in [ADR-0002: NMDP FHIR Namespace Conventions](https://github.com/ericbfriday/fhir-ig-builder/blob/main/docs/adr/0002-nmdp-fhir-namespace-conventions.md). Key decisions include:

- All NMDP terminology URIs live under `http://terminology.nmdp.org/`
- CIBMTR-specific identifiers use `http://terminology.cibmtr.org/`
- External standards (ISBT 128, LOINC, SNOMED) use their canonical URIs
- Aliases follow the pattern `$org-concept` for readability and grep-ability
