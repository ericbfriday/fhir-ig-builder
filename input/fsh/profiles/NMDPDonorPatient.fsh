Profile: NMDPDonorPatient
Parent: Patient
Id: nmdp-donor-patient
Title: "NMDP Donor Patient"
Description: "A profile representing a hematopoietic cell donor registered in the NMDP registry."

* identifier 1..* MS
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice on identifier system"
* identifier contains
    nmdpDonorId 1..1 MS and
    grid 0..1 MS
* identifier[nmdpDonorId].system 1..1
* identifier[nmdpDonorId].system = $nmdp-donor
* identifier[nmdpDonorId].value 1..1
* identifier[nmdpDonorId] ^short = "NMDP Donor ID"
* identifier[nmdpDonorId] ^definition = "The unique identifier assigned to a donor by the National Marrow Donor Program."
* identifier[grid].system 1..1
* identifier[grid].system = $isbt-grid
* identifier[grid].value 1..1
* identifier[grid] ^short = "Global Registration Identifier for Donors (GRID)"
* identifier[grid] ^definition = "The ISBT 128 Global Registration Identifier for Donors."

* name 1..* MS
* gender 1..1 MS
* birthDate 1..1 MS

* extension contains
    $us-core-race named race 0..1 and
    $us-core-ethnicity named ethnicity 0..1 and
    DonorStatus named donorStatus 0..1
* extension[race] ^short = "US Core Race"
* extension[ethnicity] ^short = "US Core Ethnicity"
* extension[donorStatus] ^short = "Donor registry status"
