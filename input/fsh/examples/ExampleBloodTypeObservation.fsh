Instance: ExampleBloodTypeObservation
InstanceOf: ExampleLabObservation
Usage: #example
Title: "Example Blood Type Observation"
Description: "An example ABO blood type observation for an NMDP donor."

* status = #final
* category = http://terminology.hl7.org/CodeSystem/observation-category#laboratory
* code = $loinc#882-1 "ABO group [Type] in Blood"
* subject = Reference(ExampleNMDPDonor)
* effectiveDateTime = "2025-01-15"
* valueCodeableConcept = $sct#112144000 "Blood group A (finding)"
