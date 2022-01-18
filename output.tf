## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

output "generated_ssh_public_key" {
  value     = tls_private_key.public_private_key_pair.public_key_openssh
  sensitive = true
}

output "vm_pan_firewall_mgmt_public_ip" {
  value = [oci_core_instance.vm_pan_firewall.public_ip]
}
