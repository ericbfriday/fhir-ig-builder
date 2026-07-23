# Contributing

Thank you for contributing to the NMDP FHIR IG Builder! This document covers our workflow, conventions, and quality expectations.

---

## How to Contribute

1. **Fork** the repository on GitHub
2. **Clone** your fork locally
3. **Create a branch** from `main` (see naming below)
4. **Make your changes** inside the devcontainer (or locally)
5. **Verify** that `pnpm sushi` compiles cleanly with 0 errors
6. **Push** your branch and open a Pull Request against `main`

---

## Branch Naming

```
feature/<issue-number>-<short-description>
fix/<issue-number>-<short-description>
docs/<issue-number>-<short-description>
chore/<short-description>
```

Examples:
- `feature/12-add-hla-typing-profile`
- `fix/15-correct-valueset-binding`
- `docs/8-rewrite-readme`

---

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <short summary>

[optional body]
[optional footer]
```

### Types

| Type | When to use |
|------|-------------|
| `feat` | New profile, extension, valueset, or feature |
| `fix` | Bug fix in FSH definitions or tooling |
| `docs` | Documentation changes only |
| `chore` | Build config, CI, dependencies, housekeeping |
| `refactor` | Restructure FSH without changing behavior |
| `test` | Adding or updating examples/test resources |

### Examples

```
feat: add NMDPDonorPatient profile

docs: update getting-started with Zed instructions

fix: correct binding strength on ethnicity extension

chore: update SUSHI to 3.14.0
```

---

## FSH Style Guide

### File organization

- **One profile, extension, valueset, or codesystem per file**
- **Filename matches the FSH entity name** — if you define `Profile: NMDPDonorPatient`, the file is `NMDPDonorPatient.fsh`
- **Directory structure:**

```
input/fsh/
├── aliases.fsh          # All URL aliases (shared across files)
├── profiles/            # Profile definitions
├── extensions/          # Extension definitions
├── valuesets/           # ValueSet definitions
├── codesystems/         # CodeSystem definitions
└── examples/            # Example instances
```

### Aliases

Use aliases from `input/fsh/aliases.fsh` for all canonical URLs. Never hard-code a URL that already has an alias:

```fsh
// ✅ Good
* status = $OBSERVATION_STATUS#final

// ❌ Bad
* status = http://hl7.org/fhir/observation-status#final
```

If you need a new URL, add the alias to `aliases.fsh` first, then use it in your FSH file.

### Naming conventions

- **Profiles:** PascalCase, prefixed with `NMDP` — e.g., `NMDPDonorPatient`
- **Extensions:** PascalCase, prefixed with `NMDP` — e.g., `NMDPEthnicityDetail`
- **ValueSets:** PascalCase with `VS` suffix — e.g., `HLALocusVS`
- **CodeSystems:** PascalCase with `CS` suffix — e.g., `NMDPDonorStatusCS`
- **Examples:** PascalCase with `Example` suffix — e.g., `NMDPDonorPatientExample`

### Examples

Every new profile or extension should include at least one example instance in `input/fsh/examples/`. This serves as both documentation and a validation check.

```fsh
Instance: NMDPDonorPatientExample
InstanceOf: NMDPDonorPatient
Title: "Example NMDP Donor Patient"
Description: "A sample donor patient demonstrating the NMDPDonorPatient profile."
Usage: #example
* identifier[0].system = "https://www.nmdp.org/global-registration-identifier"
* identifier[0].value = "GRID-12345"
* name[0].family = "Smith"
* name[0].given[0] = "Jane"
```

---

## Pull Request Requirements

Before your PR can be merged:

1. **SUSHI compiles cleanly** — `pnpm sushi` produces 0 errors (warnings are acceptable but should be addressed)
2. **Include an example** if adding a new profile or extension
3. **Update documentation** if your change affects the developer workflow
4. **Descriptive PR title** following conventional commit format
5. **Link the issue** — reference the GitHub issue number in the PR description (e.g., "Closes #12")

### PR description template

```markdown
## Summary

Brief description of what this PR does.

## Changes

- Added NMDPDonorPatient profile
- Added example instance
- Updated aliases.fsh with new system URL

## Testing

- [ ] `pnpm sushi` compiles with 0 errors
- [ ] Example instance validates against the profile
```

---

## Issue Tracker

We use [GitHub Issues](https://github.com/ericbfriday/fhir-ig-builder/issues) on this repository. When filing an issue:

- Use a descriptive title
- Include steps to reproduce (for bugs)
- Reference related profiles or FSH files
- Apply relevant labels if you have access

---

## Development Environment

The fastest way to get started is with the devcontainer. See [Getting Started](docs/dev/getting-started.md) for full setup instructions.

Quick version:

```bash
git clone https://github.com/ericbfriday/fhir-ig-builder.git
cd fhir-ig-builder
# Open in VS Code → "Reopen in Container"
pnpm sushi  # Verify everything works
```

---

## License

All contributions are made under the [Apache 2.0 License](LICENSE). By submitting a PR, you agree that your contributions will be licensed under the same terms.
