## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}
#variable "user_ocid" {}
#variable "fingerprint" {}
#variable "private_key_path" {}

variable "ssh_public_key" {
  default = ""
}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.4"
}

variable "availability_domain_name" {
  default = ""
}
variable "availability_domain_number" {
  default = 0
}

variable "igw_display_name" {
  default = "internet-gateway"
}

variable "vcn01_cidr_block" {
  default = "10.0.0.0/16"
}
variable "vcn01_dns_label" {
  default = "vcn01"
}
variable "vcn01_display_name" {
  default = "vcn01"
}

variable "vcn01_subnet_mgmt_pub01_cidr_block" {
  default = "10.0.1.0/24"
}

variable "vcn01_subnet_mgmt_pub01_display_name" {
  default = "vcn01_subnet_mgmt_pub01"
}

variable "vcn01_subnet_untrusted_pub02_cidr_block" {
  default = "10.0.2.0/24"
}

variable "vcn01_subnet_untrusted_pub02_display_name" {
  default = "vcn01_subnet_untrusted_pub02"
}

variable "vcn01_subnet_trusted_priv03_cidr_block" {
  default = "10.0.3.0/24"
}

variable "vcn01_subnet_trusted_priv03_display_name" {
  default = "vcn01_subnet_trusted_priv03"
}

variable "vcn02_cidr_block" {
  default = "10.1.0.0/16"
}
variable "vcn02_dns_label" {
  default = "vcn02"
}
variable "vcn02_display_name" {
  default = "vcn02"
}

variable "vcn02_subnet_trusted_priv04_cidr_block" {
  default = "10.1.1.0/24"
}

variable "vcn02_subnet_trusted_priv04_display_name" {
  default = "vcn02_subnet_trusted_priv04"
}

# OS Images
variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
}

variable "vm_vcn01pub02_Shape" {
  default = "VM.Standard.E3.Flex"
}

variable "vm_vcn01pub02_FlexShapeOCPUS" {
  default = 1
}

variable "vm_vcn01pub02_FlexShapeMemory" {
  default = 1
}

variable "vm_vcn02priv04_Shape" {
  default = "VM.Standard.E3.Flex"
}

variable "vm_vcn02priv04_FlexShapeOCPUS" {
  default = 1
}

variable "vm_vcn02priv04_FlexShapeMemory" {
  default = 1
}

variable "vm_vcn01priv03_Shape" {
  default = "VM.Standard.E3.Flex"
}

variable "vm_vcn01priv03_FlexShapeOCPUS" {
  default = 1
}

variable "vm_vcn01priv03_FlexShapeMemory" {
  default = 1
}

variable "vm_pan_firewall_Shape" {
  default = "VM.Standard2.4"
}

variable "vm_pan_firewall_FlexShapeOCPUS" {
  default = 1
}

variable "vm_pan_firewall_FlexShapeMemory" {
  default = 1
}

variable "vm_pan_firewall_vcn01_priv01_vnic_ip" {
  default = "10.0.1.2"
}

variable "vm_pan_firewall_vcn01_priv02_vnic_ip" {
  default = "10.0.2.2"
}

variable "vm_pan_firewall_vcn01_priv03_vnic_ip" {
  default = "10.0.3.2"
}

variable "vm_pan_firewall_vcn02_priv04_vnic_ip" {
  default = "10.1.1.2"
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_vm_vcn01pub02_shape   = contains(local.compute_flexible_shapes, var.vm_vcn01pub02_Shape)
  is_flexible_vm_vcn02priv04_shape  = contains(local.compute_flexible_shapes, var.vm_vcn02priv04_Shape)
  is_flexible_vm_vcn01priv03_shape  = contains(local.compute_flexible_shapes, var.vm_vcn01priv03_Shape)
  is_flexible_vm_pan_firewall_shape = contains(local.compute_flexible_shapes, var.vm_pan_firewall_Shape)
}



