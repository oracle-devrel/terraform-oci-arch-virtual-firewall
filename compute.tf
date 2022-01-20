## Copyright (c) 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# vm_pan_firewall 

resource "oci_core_instance" "vm_pan_firewall" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "vm_pan_firewall"
  shape               = var.vm_pan_firewall_Shape

  dynamic "shape_config" {
    for_each = local.is_flexible_vm_pan_firewall_shape ? [1] : []
    content {
      memory_in_gbs = var.vm_pan_firewall_FlexShapeMemory
      ocpus         = var.vm_pan_firewall_FlexShapeOCPUS
    }
  }

  create_vnic_details {
    subnet_id              = oci_core_subnet.vcn01_subnet_mgmt_pub01.id
    private_ip             = var.vm_pan_firewall_vcn01_priv01_vnic_ip
    display_name           = "vcn01_mgmt_vnic"
    nsg_ids                = [oci_core_network_security_group.MgmtSecurityGroup.id]
    assign_public_ip       = true
    skip_source_dest_check = true
  }

  source_details {
    source_id               = lookup(data.oci_core_app_catalog_listing_resource_version.App_Catalog_Listing_Resource_Version, "listing_resource_id")
    source_type             = "image"
    boot_volume_size_in_gbs = "60"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_vnic_attachment" "vm_pan_firewall_vcn01pub02vnic_attachment" {
  create_vnic_details {
    subnet_id              = oci_core_subnet.vcn01_subnet_untrusted_pub02.id
    display_name           = "vcn01_untrusted_vnic"
    private_ip             = var.vm_pan_firewall_vcn01_priv02_vnic_ip
    nsg_ids                = [oci_core_network_security_group.UntrustSecurityGroup.id]
    assign_public_ip       = true
    skip_source_dest_check = true
  }
  instance_id = oci_core_instance.vm_pan_firewall.id
}

resource "oci_core_vnic_attachment" "vm_pan_firewall_vcn01priv03vnic_attachment" {
  create_vnic_details {
    subnet_id              = oci_core_subnet.vcn01_subnet_trusted_priv03.id
    display_name           = "vcn01_trusted_vnic"
    private_ip             = var.vm_pan_firewall_vcn01_priv03_vnic_ip
    assign_public_ip       = false
    skip_source_dest_check = true
  }
  instance_id = oci_core_instance.vm_pan_firewall.id
}

resource "oci_core_vnic_attachment" "vm_pan_firewall_vcn02priv04vnic_attachment" {
  create_vnic_details {
    subnet_id              = oci_core_subnet.vcn02_subnet_trusted_priv04.id
    display_name           = "vcn02_trusted_vnic"
    private_ip             = var.vm_pan_firewall_vcn02_priv04_vnic_ip
    assign_public_ip       = false
    skip_source_dest_check = true
  }
  instance_id = oci_core_instance.vm_pan_firewall.id
}

# vm_vcn01pub02 in VCN01/Subnet02

resource "oci_core_instance" "vm_vcn01pub2" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "vm_vcn01pub02"
  shape               = var.vm_vcn01pub02_Shape

  dynamic "shape_config" {
    for_each = local.is_flexible_vm_vcn01pub02_shape ? [1] : []
    content {
      memory_in_gbs = var.vm_vcn01pub02_FlexShapeMemory
      ocpus         = var.vm_vcn01pub02_FlexShapeOCPUS
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn01_subnet_untrusted_pub02.id
    display_name     = "vm_vcn01pub02_vnic"
    assign_public_ip = true
  }

  source_details {
    source_type             = "image"
    source_id               = lookup(data.oci_core_images.vm_vcn01pub02_ImageOCID.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  # Needed for bastion agent to start on the compute
  provisioner "local-exec" {
    command = "sleep 240"
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# vm_vcn01priv03 in VCN01/Subnet03

resource "oci_core_instance" "vm_vcn01priv03" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "vm_vcn01priv03"
  shape               = var.vm_vcn01priv03_Shape

  dynamic "shape_config" {
    for_each = local.is_flexible_vm_vcn01priv03_shape ? [1] : []
    content {
      memory_in_gbs = var.vm_vcn01priv03_FlexShapeMemory
      ocpus         = var.vm_vcn01priv03_FlexShapeOCPUS
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn01_subnet_trusted_priv03.id
    display_name     = "vm_vcn01priv03_vnic"
    assign_public_ip = false
  }

  source_details {
    source_type             = "image"
    source_id               = lookup(data.oci_core_images.vm_vcn01priv03_ImageOCID.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

data "oci_core_vnic_attachments" "vm_vcn01priv03_primaryvnic_attach" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.vm_vcn01priv03.id
}

data "oci_core_vnic" "vm_vcn01pub2_primaryvnic" {
  vnic_id = data.oci_core_vnic_attachments.vm_vcn01priv03_primaryvnic_attach.vnic_attachments.0.vnic_id
}

# vm_vcn02priv04 in VCN02/Subnet04

resource "oci_core_instance" "vm_vcn02priv04" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "vm_vcn02priv04"
  shape               = var.vm_vcn02priv04_Shape

  dynamic "shape_config" {
    for_each = local.is_flexible_vm_vcn02priv04_shape ? [1] : []
    content {
      memory_in_gbs = var.vm_vcn02priv04_FlexShapeMemory
      ocpus         = var.vm_vcn02priv04_FlexShapeOCPUS
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn02_subnet_trusted_priv04.id
    display_name     = "vm_vcn02priv04_vnic"
    assign_public_ip = false
  }

  source_details {
    source_type             = "image"
    source_id               = lookup(data.oci_core_images.vm_vcn02priv04_ImageOCID.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

data "oci_core_vnic_attachments" "vm_vcn02priv04_primaryvnic_attach" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.vm_vcn02priv04.id
}

data "oci_core_vnic" "vm_vcn02priv04_primaryvnic" {
  vnic_id = data.oci_core_vnic_attachments.vm_vcn02priv04_primaryvnic_attach.vnic_attachments.0.vnic_id
}



