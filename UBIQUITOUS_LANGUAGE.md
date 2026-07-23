# Ubiquitous Language

## FHIR IG Development

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Implementation Guide (IG)** | A published set of FHIR profiles, extensions, value sets, and documentation that constrains base FHIR resources for a specific use case | Spec, specification, schema |
| **FHIR Shorthand (FSH)** | A domain-specific language for authoring FHIR artifacts (profiles, extensions, value sets, examples) in a compact human-readable syntax | FHIR DSL, shorthand |
| **SUSHI** | The reference compiler that transforms FSH source files into FHIR JSON/XML conformance resources (SUSHI Unshortens Short Hand Inputs) | FSH compiler, transpiler |
| **GoFSH** | A decompiler that converts existing FHIR JSON/XML artifacts back into FSH source files | Reverse SUSHI, FSH converter |
| **IG Publisher** | A Java-based tool (JAR) that takes FHIR conformance resources and narrative pages and produces a complete, publishable HTML implementation guide | Publisher, build tool |
| **Profile** | A StructureDefinition that constrains a base FHIR resource type for a specific use case (e.g., "CIBMTR Patient" constrains Patient) | Constraint, schema |
| **Extension** | A FHIR mechanism for adding data elements not present in the base resource specification | Custom field, extra attribute |
| **ValueSet** | A curated set of coded values drawn from one or more code systems, bound to a profile element | Code list, enumeration |
| **CodeSystem** | A collection of codes with associated meanings that define a vocabulary for a domain | Terminology, lookup table |
| **Conformance Resource** | Any FHIR resource that defines structure or vocabulary (StructureDefinition, ValueSet, CodeSystem, CapabilityStatement) | Metadata resource |
| **Canonical URL** | A globally unique, version-independent URL that identifies a conformance resource | Official URL, identifier |

## NMDP Identifiers & Terminology

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **GRID** | Global Registration Identifier for Donors — a unique, internationally-assigned identifier for registered donors (system: `http://www.isbt128.org/uri/GRID`) | Donor GRID, ICCBBA ID |
| **NMDP Donor ID** | A numeric identifier assigned by NMDP's registry to an individual donor (system: `http://terminology.nmdp.org/identifier/donor`) | Registry ID, donor number |
| **CBU ID** | Identifier assigned to a Cord Blood Unit in the NMDP registry (system: `http://terminology.nmdp.org/identifier/cbu`) | Cord ID, unit ID |
| **CRID** | CIBMTR Research ID — a patient identifier assigned by CIBMTR for research tracking (system: `http://terminology.cibmtr.org/identifier/CRID`) | Research ID, CIBMTR ID |
| **HML ID** | Identifier for an HML message submission (system: `http://terminology.nmdp.org/identifier/hmlid`) | Message ID, submission ID |
| **Local ID** | A center-assigned identifier for a donor or patient within the submitting organization (system: `http://terminology.nmdp.org/identifier/local-id`) | Internal ID, center ID |
| **System URI** | The FHIR `Identifier.system` value that declares the namespace an identifier belongs to | Namespace, OID |

## HLA & Genomics

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **HLA** | Human Leukocyte Antigen — a set of genes on chromosome 6 that encode cell-surface proteins critical for immune system function and transplant matching | MHC, tissue type |
| **Locus** | A specific HLA gene position (e.g., HLA-A, HLA-B, HLA-DRB1) that is independently typed and reported | Gene, marker |
| **GL String** | Genotype List String — a text notation for representing HLA genotyping results including ambiguity (e.g., `HLA-A*01:01+HLA-A*02:01`) | Genotype string, allele string |
| **GL String Code (GLSC)** | A compact hash-based code derived from a GL String that can serve as a CodeableConcept code in FHIR observations | GL code, GLSC hash |
| **PL String** | Protein-Level String — a newer notation for expressing HLA typing at the protein (serological equivalence) level | Protein string |
| **PTR** | Preferred Test Result — the computed best/most informative HLA typing result for each locus, selected algorithmically from all available test results | Best result, preferred result |
| **Allele** | A specific variant of an HLA gene at a particular locus, named per WHO/IMGT nomenclature (e.g., `HLA-A*02:01:01:01`) | Variant, type |
| **High Resolution Typing** | HLA typing that resolves at least the first two fields of allele nomenclature (e.g., `HLA-A*02:01`) | HR typing, molecular typing |
| **KIR** | Killer-cell Immunoglobulin-like Receptor — a set of genes relevant to NK cell function that may influence transplant outcomes | NK receptor |

## Domain Entities (Clinical)

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Donor** | An individual registered in the NMDP registry who may provide hematopoietic cells for transplant; represented as a FHIR Patient resource | Source, volunteer |
| **Recipient** | A patient who receives (or is being evaluated to receive) hematopoietic cells from a donor | Patient (ambiguous), transplant patient |
| **CBU** | Cord Blood Unit — a stored unit of cord blood from a single collection, treated as a donor-equivalent in matching; may be modeled as a Patient with a distinguishing profile | Cord, unit, cord blood |
| **Transplant Center (TC)** | A medical facility that performs hematopoietic cell transplants and interacts with NMDP for donor coordination | Hospital, center |
| **Donor Center (DC)** | A facility responsible for recruiting, managing, and facilitating donors in the registry | Registry, recruitment center |
| **Collection Center (CC)** | A facility that performs the physical collection (apheresis or marrow harvest) of hematopoietic cells from a donor | Harvest center |
| **Apheresis Center (AC)** | A facility specifically equipped for apheresis procedures to collect peripheral blood stem cells | Pheresis center |
| **HCT** | Hematopoietic Cell Transplantation — the clinical procedure of transferring stem cells from a donor to a recipient | Bone marrow transplant, BMT, stem cell transplant |

## Domain Entities (Technical)

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **HML** | Histoimmunogenetics Markup Language — an XML schema for transmitting HLA typing data from labs to registries | Typing message, lab XML |
| **HML Gateway** | The NMDP service that receives, validates, and routes HML messages, converting them to FHIR for storage in HealthLake | HML2FHIR, gateway |
| **AGNIS** | A Growable Network Information System — CIBMTR's automated messaging system for collecting transplant data | Messaging system |
| **FormsNet3 (FN3)** | CIBMTR's web-based manual data entry system for transplant center staff to submit clinical data | Forms, data entry |
| **ODS** | Operational Data Services — NMDP's backend SOAP/REST service layer that exposes donor demographics, orders, typing, and eligibility data | Backend services, data services |
| **AWS HealthLake** | Amazon's managed FHIR-compliant data store used by NMDP's Genomic Services team as the system of record | FHIR server, data store |
| **CIBMTR** | Center for International Blood & Marrow Transplant Research — the research arm (NMDP + Medical College of Wisconsin) that collects and analyzes transplant outcomes | Research registry |

## FHIR IG Tooling & Infrastructure

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Devcontainer** | A Docker-based development environment specification (`.devcontainer/`) that provides a reproducible toolchain for IG authoring | Dev environment, Docker dev |
| **ig.ini** | A configuration file at the IG root that tells the IG Publisher which ImplementationGuide resource to build and where to find it | Publisher config |
| **sushi-config.yaml** | The SUSHI configuration file that declares IG metadata (id, canonical, dependencies, pages) and is the single source of truth for an FSH-based IG | Config, SUSHI settings |
| **input/fsh/** | The directory containing FSH source files (.fsh) that SUSHI compiles into FHIR artifacts | FSH source, source directory |
| **input-cache/** | A local cache directory holding the IG Publisher JAR and downloaded dependency packages | Cache, publisher cache |
| **_updatePublisher.sh** | A script that downloads the latest IG Publisher JAR into input-cache/ | Update script |
| **_genonce.sh** | A script that runs SUSHI and then the IG Publisher to produce the IG output once | Build script, gen script |

## Relationships

- A **Donor** is identified by exactly one **GRID** and one **NMDP Donor ID**
- A **Donor** has **PTR** (one per **Locus**), each expressed as a **GL String**
- A **CBU** follows the same identifier and observation patterns as a **Donor**
- A **Recipient** is identified by a **CRID** once registered with CIBMTR
- An **HML** message is converted to FHIR resources by the **HML Gateway** and stored in **AWS HealthLake**
- A **Profile** constrains a base FHIR resource; an **Extension** adds new elements to it
- An **IG** contains **Profiles**, **Extensions**, **ValueSets**, and **CodeSystems**
- **FSH** source files are compiled by **SUSHI** into conformance resources, then the **IG Publisher** builds the final HTML site
- The **CIBMTR Reporting IG** depends on US Core and mCODE and defines the data contract for transplant centers

## Example dialogue

> **Dev:** "When a lab submits an **HML** message, does it go directly into **HealthLake**?"
>
> **Domain expert:** "No — **HML Gateway** validates and converts it first. The HML is parsed into FHIR Observations using **GL String** values per **Locus**, then stored as a bundle in **HealthLake**."
>
> **Dev:** "And the **PTR** — is that the same as what comes in from HML?"
>
> **Domain expert:** "Not necessarily. The **PTR** is computed by **ODS** from all available test results for a **Donor** at a given **Locus**. A single **HML** submission adds typing data, but **PTR** is the algorithmically-selected best result across all submissions."
>
> **Dev:** "So for the **FHIR Donor API**, we serve the **PTR** as Observations on the Patient?"
>
> **Domain expert:** "Yes. Each **Locus** gets its own Observation with a LOINC code and the **GL String Code** in `valueCodeableConcept`. The full typing history is a v2 concern."
>
> **Dev:** "And the **IG** we're building — does it just define the **Profiles** for this API, or also for CIBMTR reporting?"
>
> **Domain expert:** "They're separate **IGs**. The **CIBMTR Reporting IG** already exists at fhir.nmdp.org. Ours defines the Donor API contract — Patient profile, HLA Observation profile, ServiceRequest for orders, and NMDP-specific **Extensions** like donor-status."

## Flagged ambiguities

- **"Patient"** is used to mean both **Donor** and **Recipient** in FHIR (both map to the Patient resource). The distinction is made via profiles and identifier systems. Use **Donor** or **Recipient** in domain language; use "Patient resource" only when referring to the FHIR resource type.
- **"identifier"** is overloaded — could mean a FHIR `Identifier` data type, or the domain concept of a **GRID**/**NMDP Donor ID**/**CRID**. Prefer the specific identifier name in domain conversations.
- **"IG"** can refer to the published specification document OR the toolchain/repo that builds it. Prefer "**IG**" for the published artifact, "**IG project**" or "**IG source**" for the development repository.
- **"FHIR server"** is ambiguous — could mean **AWS HealthLake** (the actual data store) or the CIBMTR Direct FHIR API endpoint. Be specific about which service you mean.
- **"HML-to-FHIR"** can refer to the general concept of conversion, the **HML Gateway** application, or the older `nmdp-bioinformatics/hml-fhir-app`. Prefer "**HML Gateway**" for the current production system.
