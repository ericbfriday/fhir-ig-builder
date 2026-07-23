# NMDP FHIR IG Builder Template

This is a **template Implementation Guide** for NMDP (National Marrow Donor Program / Be The Match) teams to fork and use as the starting point for new FHIR IGs. It provides a complete project scaffold including example profiles, a CI pipeline, a devcontainer-based development environment, and this documentation structure.

## What's Included

- **Example profiles**: [NMDPDonorPatient](StructureDefinition-NMDPDonorPatient.html), [ExampleLabObservation](StructureDefinition-ExampleLabObservation.html), and [ExampleDonorOrder](StructureDefinition-ExampleDonorOrder.html) demonstrate NMDP conventions
- **Shared aliases**: A curated `aliases.fsh` with all NMDP identifier systems and code systems
- **CI pipeline**: GitHub Actions workflow for continuous validation and publishing
- **Devcontainer**: One-click reproducible environment with Node.js, pnpm, SUSHI, and JDK 17
- **Documentation structure**: Narrative pages, ADRs, and developer guides

## Getting Started

### 1. Fork and Rename

1. Fork the [fhir-ig-builder repository](https://github.com/ericbfriday/fhir-ig-builder)
2. Rename your fork to match your IG (e.g., `fhir-ig-donor-typing`)
3. Update `sushi-config.yaml` with your IG's canonical URL, name, and metadata
4. Update `ig.ini` with the matching IG identifier

### 2. Replace Example Profiles

The template ships with example profiles to demonstrate conventions. Replace them with your own:

1. Delete the example `.fsh` files under `input/fsh/profiles/`
2. Create your profiles following the [Conventions](conventions.html) page
3. Use the identifier systems documented on the [Identifiers](identifiers.html) page
4. Add at least one example instance per profile in `input/fsh/examples/`

### 3. Build and Validate

```bash
# Open in VS Code → "Reopen in Container" when prompted
# Or use any Docker-compatible runtime (OrbStack, Podman 5+, etc.)

pnpm sushi        # Compile FSH → FHIR JSON
pnpm validate     # Run SUSHI + IG Publisher validation
pnpm build        # Full IG Publisher build
```

See the [repository README](https://github.com/ericbfriday/fhir-ig-builder) and the devcontainer setup guide for full details.

## Documentation

- [Conventions](conventions.html) — IG authoring standards: naming, aliases, terminology, and US Core alignment
- [Identifiers](identifiers.html) — NMDP identifier system URIs and usage patterns
- [Artifacts](artifacts.html) — All conformance resources defined in this IG

## Links

- [GitHub Repository](https://github.com/ericbfriday/fhir-ig-builder)
- [NMDP FHIR Homepage](https://www.nmdp.org)
- [FHIR Shorthand School](https://fshschool.org/)
- [HL7 FHIR R4](https://hl7.org/fhir/R4/)
