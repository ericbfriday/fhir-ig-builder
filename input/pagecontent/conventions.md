# IG Authoring Conventions

This page documents the authoring conventions for NMDP FHIR Implementation Guides. All IGs derived from this template should follow these standards to ensure consistency across the organization.

## Extension Namespace

All NMDP-defined extensions use the base URL:

```
http://fhir.nmdp.org/StructureDefinition
```

This is available as the FSH alias `$nmdp-ext`. When defining a new extension, its canonical URL will be `http://fhir.nmdp.org/StructureDefinition/YourExtensionName`.

## Alias Usage

**Rule: Always define aliases in `aliases.fsh`. Never inline URLs in profiles.**

Every system URI, code system, value set, or extension URL referenced in FSH files must have a corresponding alias in `input/fsh/aliases.fsh`. This ensures:

- A single source of truth for all URLs
- Easy refactoring if a URL changes
- Consistent usage across all profiles in the IG
- Better readability in FSH source files

When adding a new alias, follow the naming pattern `$org-concept` (e.g., `$nmdp-donor`, `$cibmtr-crid`, `$loinc`).

## Terminology Patterns

Choose the appropriate code system based on the concept type:

| Concept Type | Code System | When to Use |
|-------------|-------------|-------------|
| Lab observations | LOINC (`$loinc`) | Standard observation codes for lab results, vitals, and clinical measurements |
| Clinical findings | SNOMED CT (`$sct`) | Diagnoses, procedures, body sites, and clinical concepts |
| NMDP center types | `$nmdp-center-type` | Donor centers, transplant centers, collection centers, apheresis centers |
| NMDP donor centers | `$nmdp-donor-center` | Specific donor center identifiers |
| Subject types | `$cibmtr-subject-type` | CIBMTR research subject classifications |

**Prefer international standards** (LOINC, SNOMED CT) wherever an appropriate code exists. Use NMDP-local code systems only for concepts that have no standard representation.

## Profile Naming

Use **PascalCase** with descriptive names that communicate the profile's purpose:

| ✅ Good | ❌ Avoid |
|---------|----------|
| `NMDPDonorPatient` | `DonorPt` |
| `ExampleLabObservation` | `LabObs` |
| `ExampleDonorOrder` | `Order1` |
| `HLATypingSpecimen` | `Spec` |

Guidelines:
- Prefix with `NMDP` when the profile is organization-specific
- Use the FHIR resource type as a suffix (e.g., `...Patient`, `...Observation`)
- Be explicit — a reader should understand the profile's scope from its name alone

## Example Instances

**Every profile must include at least one valid example instance.**

Place examples in `input/fsh/examples/` and ensure they:

- Demonstrate all required fields and slices
- Use realistic (but fictional) data
- Pass SUSHI compilation without errors
- Include the `Usage: #example` declaration

```fsh
Instance: ExampleDonor
InstanceOf: NMDPDonorPatient
Usage: #example
Title: "Example NMDP Donor"
Description: "A sample donor patient demonstrating all required fields."
* identifier[donorId].system = $nmdp-donor
* identifier[donorId].value = "12345678"
* name.given = "Jane"
* name.family = "Doe"
* gender = #female
* birthDate = "1990-03-15"
```

## US Core Alignment

**Derive from US Core profiles where applicable.** This IG declares a dependency on [US Core 6.1.0](https://hl7.org/fhir/us/core/STU6.1/), and NMDP profiles should extend US Core rather than base FHIR resources whenever a corresponding US Core profile exists.

Common US Core base profiles:

| NMDP Use Case | Derive From |
|--------------|-------------|
| Patient demographics | `USCorePatientProfile` |
| Lab results | `USCoreLaboratoryResultObservationProfile` |
| Service requests | `USCoreServiceRequestProfile` |
| Diagnostic reports | `USCoreDiagnosticReportProfileLaboratoryReporting` |
| Specimens | Base FHIR `Specimen` (no US Core profile) |

When deriving from US Core, your profile inherits its must-support elements and constraints. Add NMDP-specific extensions and slices on top of the US Core foundation.
