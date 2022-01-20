## Copyright (c) 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "vcn01" {
  cidr_block     = var.vcn01_cidr_block
  dns_label      = var.vcn01_dns_label
  compartment_id = var.compartment_ocid
  display_name   = var.vcn01_display_name
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_vcn" "vcn02" {
  cidr_block     = var.vcn02_cidr_block
  dns_label      = var.vcn02_dns_label
  compartment_id = var.compartment_ocid
  display_name   = var.vcn02_display_name
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#IGW
resource "oci_core_internet_gateway" "vcn01_internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "vcn01_internet_gateway"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "vcn01_mgmt_igw_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "vcn01_mgmt_igw_route_table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.vcn01_internet_gateway.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "vcn01_pub02_igw_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "vcn01_pub02_igw_route_table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.vcn01_internet_gateway.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#NAT
resource "oci_core_nat_gateway" "vcn01_nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "vcn01_nat_gateway"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

data "oci_core_private_ips" "vm_pan_firewall_vcn01priv03vnic_ip" {
  vnic_id = oci_core_vnic_attachment.vm_pan_firewall_vcn01priv03vnic_attachment.vnic_id
}

resource "oci_core_route_table" "vcn01_priv03_paloalto_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "vcn01_priv03_paloalto_route_table"
  
  #route_rules {
  #  network_entity_id = oci_core_nat_gateway.vcn01_nat_gateway.id
  #  destination       = "0.0.0.0/0"
  #  destination_type  = "CIDR_BLOCK"
  #}

  route_rules {
    network_entity_id = lookup(element(lookup(data.oci_core_private_ips.vm_pan_firewall_vcn01priv03vnic_ip, "private_ips"), 0), "id")
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }  

  route_rules {
    network_entity_id = lookup(element(lookup(data.oci_core_private_ips.vm_pan_firewall_vcn01priv03vnic_ip, "private_ips"), 0), "id")
    destination       = var.vcn02_subnet_trusted_priv04_cidr_block
    destination_type  = "CIDR_BLOCK"
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

data "oci_core_private_ips" "vm_pan_firewall_vcn02priv04vnic_ip" {
  vnic_id = oci_core_vnic_attachment.vm_pan_firewall_vcn02priv04vnic_attachment.vnic_id
}

resource "oci_core_route_table" "vcn02_priv04_paloalto_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn02.id
  display_name   = "vcn02_priv04_paloalto_route_table"

  route_rules {
    network_entity_id = lookup(element(lookup(data.oci_core_private_ips.vm_pan_firewall_vcn02priv04vnic_ip, "private_ips"), 0), "id")
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_security_list" "vcn01_pub02_seclist" {
  compartment_id = var.compartment_ocid
  display_name   = ""
  vcn_id         = oci_core_vcn.vcn01.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


#vcn01 mgmt pub01 subnet
resource "oci_core_subnet" "vcn01_subnet_mgmt_pub01" {
  cidr_block      = var.vcn01_subnet_mgmt_pub01_cidr_block
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_vcn.vcn01.id
  display_name    = var.vcn01_subnet_mgmt_pub01_display_name
  route_table_id  = oci_core_route_table.vcn01_mgmt_igw_route_table.id
  dhcp_options_id = oci_core_vcn.vcn01.default_dhcp_options_id
  defined_tags    = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#vcn01 pub02 subnet
resource "oci_core_subnet" "vcn01_subnet_untrusted_pub02" {
  cidr_block      = var.vcn01_subnet_untrusted_pub02_cidr_block
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_vcn.vcn01.id
  display_name    = var.vcn01_subnet_untrusted_pub02_display_name
  route_table_id  = oci_core_route_table.vcn01_pub02_igw_route_table.id
  dhcp_options_id = oci_core_vcn.vcn01.default_dhcp_options_id
  security_list_ids = [oci_core_security_list.vcn01_pub02_seclist.id]
  defined_tags    = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#vcn01 priv03 subnet 
resource "oci_core_subnet" "vcn01_subnet_trusted_priv03" {
  cidr_block                 = var.vcn01_subnet_trusted_priv03_cidr_block
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn01.id
  display_name               = var.vcn01_subnet_trusted_priv03_display_name
  dhcp_options_id            = oci_core_vcn.vcn01.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table_attachment" "vcn01_subnet_trusted_priv03_route_table_attachment" {
  subnet_id      = oci_core_subnet.vcn01_subnet_trusted_priv03.id
  route_table_id = oci_core_route_table.vcn01_priv03_paloalto_route_table.id
}

#vcn02 priv04 subnet 
resource "oci_core_subnet" "vcn02_subnet_trusted_priv04" {
  cidr_block                 = var.vcn02_subnet_trusted_priv04_cidr_block
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn02.id
  display_name               = var.vcn02_subnet_trusted_priv04_display_name
  dhcp_options_id            = oci_core_vcn.vcn02.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table_attachment" "vcn02_subnet_trusted_priv04_route_table_attachment" {
  subnet_id      = oci_core_subnet.vcn02_subnet_trusted_priv04.id
  route_table_id = oci_core_route_table.vcn02_priv04_paloalto_route_table.id
}
