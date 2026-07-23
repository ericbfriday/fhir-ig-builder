# ADR-0002: Standardize NMDP FHIR Namespace Conventions Across IGs

**Status:** Proposed  
**Date:** 2026-07-22  
**Deciders:** Eric Friday, MatchSync team  

## Context

NMDP has accumulated two generations of System URIs for identifiers and code systems:

- **Deprecated (preliminary)**: `http://nmdp.org/identifier/...`, `http://cibmtr.org/identifier/...`
- **Current (proposed/canonical)**: `http://terminology.nmdp.org/identifier/...`, `http://terminology.cibmtr.org/identifier/...`

The AGNIS-on-FHIR Confluence page documents the migration path, but adoption is inconsistent. Some systems (DTE, HML2FHIR) still use deprecated URIs. The CIBMTR Reporting IG has its own patterns. The IDM IG uses `http://example.org/` placeholders. The FHIR Donor API uses the new `terminology.nmdp.org` URIs.

Additionally, the extension namespace (`http://fhir.nmdp.org/StructureDefinition/`) is used by multiple IGs but there's no shared registry of extensions.

## Decision

This IG builder template will include a shared `input/fsh/aliases.fsh` file that declares canonical FSH aliases for all official NMDP namespaces. All IGs built from this template inherit these aliases.

```fsh
// === NMDP Identifier Systems ===
Alias: $nmdp-donor = http://terminology.nmdp.org/identifier/donor
Alias: $nmdp-cbu = http://terminology.nmdp.org/identifier/cbu
Alias: $nmdp-recipient = http://terminology.nmdp.org/identifier/recipient
Alias: $nmdp-local-id = http://terminology.nmdp.org/identifier/local-id
Alias: $nmdp-order = http://terminology.nmdp.org/identifier/order
Alias: $nmdp-hmlid = http://terminology.nmdp.org/identifier/hmlid
Alias: $nmdp-specimen = http://terminology.nmdp.org/identifier/specimen
Alias: $isbt-grid = http://www.isbt128.org/uri/GRID
Alias: $cibmtr-crid = http://terminology.cibmtr.org/identifier/CRID

// === NMDP Code Systems ===
Alias: $nmdp-center-type = http://terminology.nmdp.org/codesystem/center-type
Alias: $nmdp-donor-center = http://terminology.nmdp.org/codesystem/donor-center
Alias: $nmdp-tc = http://terminology.nmdp.org/codesystem/transplant-center
Alias: $nmdp-cc = http://terminology.nmdp.org/codesystem/collection-center
Alias: $nmdp-ac = http://terminology.nmdp.org/codesystem/apheresis-center
Alias: $cibmtr-tc = http://terminology.cibmtr.org/codesystem/transplant-center
Alias: $cibmtr-subject-type = http://terminology.cibmtr.org/codesystem/subject-type

// === NMDP Extension Base ===
Alias: $nmdp-ext = http://fhir.nmdp.org/StructureDefinition

// === External Systems ===
Alias: $loinc = http://loinc.org
Alias: $sct = http://snomed.info/sct
Alias: $us-core-race = http://hl7.org/fhir/us/core/StructureDefinition/us-core-race
Alias: $us-core-ethnicity = http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity
```

## Consequences

### Positive
- All NMDP IGs use consistent, correct URIs by default
- Developers don't need to look up the AGNIS-on-FHIR page — aliases are in the project
- FSH code is readable (uses `$nmdp-donor` instead of full URL)
- Deprecated URIs are excluded — no accidentally using old patterns
- Easy to extend as new namespaces are assigned

### Negative
- Creates a coupling between this template and the AGNIS namespace registry
- If URIs change again, all IGs need to update their aliases.fsh (but this is a feature — it forces coordinated migration)

### Risks
- The "proposed" URIs on the AGNIS-on-FHIR page may not yet be fully ratified by all stakeholders. Mitigated: the FHIR Donor API team has already adopted them, and the page explicitly says "USE this list for all new work."
