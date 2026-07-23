Profile: ExampleDonorOrder
Parent: ServiceRequest
Id: example-donor-order
Title: "Example Donor Order"
Description: "Demonstrates how NMDP models donor/CBU orders as ServiceRequests."

* intent = #order
* status MS

* identifier 1..* MS
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice on identifier system"
* identifier contains
    nmdpOrderId 1..1 MS
* identifier[nmdpOrderId].system 1..1
* identifier[nmdpOrderId].system = $nmdp-order
* identifier[nmdpOrderId].value 1..1
* identifier[nmdpOrderId] ^short = "NMDP Order ID"
* identifier[nmdpOrderId] ^definition = "The unique order identifier assigned by the NMDP system."

* subject 1..1 MS
* subject only Reference(NMDPDonorPatient)

* authoredOn 1..1 MS

* code 0..1 MS
