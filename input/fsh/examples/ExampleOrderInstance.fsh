Instance: ExampleOrderInstance
InstanceOf: ExampleDonorOrder
Usage: #example
Title: "Example Donor Order"
Description: "An example donor order for a PBSC collection."

* status = #active
* intent = #order
* identifier[nmdpOrderId].system = $nmdp-order
* identifier[nmdpOrderId].value = "ORD-2024-12345"
* subject = Reference(ExampleNMDPDonor)
* authoredOn = "2024-01-15"
* code.coding = http://terminology.nmdp.org/codesystem/order-type#pbsc-collection "PBSC Collection"
