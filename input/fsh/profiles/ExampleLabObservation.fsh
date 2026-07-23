Profile: ExampleLabObservation
Parent: Observation
Id: example-lab-observation
Title: "Example Laboratory Observation"
Description: "An example profile demonstrating terminology bindings for laboratory observations in the NMDP FHIR IG template."

* status MS
* category 1..* MS
* category = http://terminology.hl7.org/CodeSystem/observation-category#laboratory
* code MS
* code from http://loinc.org (extensible)
* subject 1..1 MS
* subject only Reference(NMDPDonorPatient)
* effective[x] MS
* value[x] only CodeableConcept
* value[x] MS
* valueCodeableConcept from ExampleABOBloodTypeVS (extensible)
