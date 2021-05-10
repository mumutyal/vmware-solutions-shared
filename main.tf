# Configure the VMware vCloud Director Provider
locals {

  publiciplist = split("," , var.VM_Public_ips)
  totalVMs = length(local.publiciplist)

}
provider "vcd" {
  user     = var.vcd_user
  password = var.vcd_password
  org      = var.vcd_org
  url      = var.vcd_url
  vdc      = var.vdc_name
}

# Used to obtain information from the already deployed Edge Gateway
module ibm_vmware_solutions_shared_instance {
  source = "./modules/ibm-vmware-solutions-shared-instance/"

  vdc_edge_gateway_name = var.vdc_edge_gateway_name
}

# Create a routed network
resource "vcd_network_routed" "tutorial_network_new" {

  name         = "Tutorial-Network-New"
  edge_gateway = module.ibm_vmware_solutions_shared_instance.edge_gateway_name
  gateway      = "192.168.100.1"

  interface_type = "distributed"

  static_ip_pool {
    start_address = "192.168.100.5"
    end_address   = "192.168.100.254"
  }

  dns1 = "9.9.9.9"
  dns2 = "1.1.1.1"
}

# Create the firewall rule to access the Internet 
resource "vcd_nsxv_firewall_rule" "rule_internet" {
  edge_gateway = module.ibm_vmware_solutions_shared_instance.edge_gateway_name
  name         = "${vcd_network_routed.tutorial_network_new.name}-Internet"

  action = "accept"

  source {
    org_networks = [vcd_network_routed.tutorial_network_new.name]
  }

  destination {
    ip_addresses = []
  }

  service {
    protocol = "any"
  }
}

# Create SNAT rule to access the Internet
resource "vcd_nsxv_snat" "rule_internet" {

  count             = local.totalVMs
  edge_gateway = module.ibm_vmware_solutions_shared_instance.edge_gateway_name
  network_type = "ext"
  network_name = module.ibm_vmware_solutions_shared_instance.external_network_name_2

  original_address   = "${vcd_network_routed.tutorial_network_new.gateway}/24"
  translated_address = element(local.publiciplist, count.index)
}

# Create the firewall rule to allow SSH from the Internet
resource "vcd_nsxv_firewall_rule" "rule_internet_ssh" {
  count = tobool(var.allow_ssh) == true ? 1 :0

  edge_gateway = module.ibm_vmware_solutions_shared_instance.edge_gateway_name
  name         = "${vcd_network_routed.tutorial_network_new.name}-Internet-SSH"

  action = "accept"

  source {
    ip_addresses = []
  }

  destination {
    ip_addresses = ["any"]
  }

  service {
    protocol = "tcp"
    port     = 22
  }
}

# Create DNAT rule to allow SSH from the Internet
resource "vcd_nsxv_dnat" "rule_internet_ssh1" {
  count = tobool(var.allow_ssh) == true ? 1 :0

  edge_gateway = module.ibm_vmware_solutions_shared_instance.edge_gateway_name
  network_type = "ext"
  network_name = module.ibm_vmware_solutions_shared_instance.external_network_name_2

  original_address =  element(local.publiciplist, 0)

  original_port    = 22

  translated_address = vcd_vapp_vm.vm_1.network[0].ip
  translated_port    = 22
  protocol           = "tcp"
}
# Create DNAT rule to allow SSH from the Internet
resource "vcd_nsxv_dnat" "rule_internet_ssh2" {
  count = tobool(var.allow_ssh) == true ? 1 :0

  edge_gateway = module.ibm_vmware_solutions_shared_instance.edge_gateway_name
  network_type = "ext"
  network_name = module.ibm_vmware_solutions_shared_instance.external_network_name_2

  original_address = element(local.publiciplist, 1)
  original_port    = 22

  translated_address = vcd_vapp_vm.vm_2.network[0].ip
  translated_port    = 22
  protocol           = "tcp"
}
# Create DNAT rule to allow SSH from the Internet
resource "vcd_nsxv_dnat" "rule_internet_ssh3" {
  count = tobool(var.allow_ssh) == true ? 1 :0

  edge_gateway = module.ibm_vmware_solutions_shared_instance.edge_gateway_name
  network_type = "ext"
  network_name = module.ibm_vmware_solutions_shared_instance.external_network_name_2

  original_address = element(local.publiciplist, 2)
  original_port    = 22

  translated_address = vcd_vapp_vm.vm_3.network[0].ip
  translated_port    = 22
  protocol           = "tcp"
}
# Create DNAT rule to allow SSH from the Internet
resource "vcd_nsxv_dnat" "rule_internet_ssh4" {
  count = tobool(var.allow_ssh) == true ? 1 :0

  edge_gateway = module.ibm_vmware_solutions_shared_instance.edge_gateway_name
  network_type = "ext"
  network_name = module.ibm_vmware_solutions_shared_instance.external_network_name_2

  original_address =  element(local.publiciplist, 3)

  original_port    = 22

  translated_address = vcd_vapp_vm.vm_4.network[0].ip
  translated_port    = 22
  protocol           = "tcp"
}
# Create DNAT rule to allow SSH from the Internet
resource "vcd_nsxv_dnat" "rule_internet_ssh5" {
  count = tobool(var.allow_ssh) == true ? 1 :0

  edge_gateway = module.ibm_vmware_solutions_shared_instance.edge_gateway_name
  network_type = "ext"
  network_name = module.ibm_vmware_solutions_shared_instance.external_network_name_2

  original_address = element(local.publiciplist, 4)
  original_port    = 22

  translated_address = vcd_vapp_vm.vm_5.network[0].ip
  translated_port    = 22
  protocol           = "tcp"
}
# Create DNAT rule to allow SSH from the Internet
resource "vcd_nsxv_dnat" "rule_internet_ssh6" {
  count = tobool(var.allow_ssh) == true ? 1 :0

  edge_gateway = module.ibm_vmware_solutions_shared_instance.edge_gateway_name
  network_type = "ext"
  network_name = module.ibm_vmware_solutions_shared_instance.external_network_name_2

  original_address = element(local.publiciplist, 5)
  original_port    = 22

  translated_address = vcd_vapp_vm.vm_6.network[0].ip
  translated_port    = 22
  protocol           = "tcp"
}

# Create the firewall to access IBM Cloud services over the IBM Cloud private network 
resource "vcd_nsxv_firewall_rule" "rule_ibm_private" {
  edge_gateway = module.ibm_vmware_solutions_shared_instance.edge_gateway_name
  name         = "${vcd_network_routed.tutorial_network_new.name}-IBM-Private"

  logging_enabled = "false"
  action          = "accept"

  source {
    org_networks = [vcd_network_routed.tutorial_network_new.name]
  }

  destination {
    gateway_interfaces = [module.ibm_vmware_solutions_shared_instance.external_network_name_1]
  }

  service {
    protocol = "any"
  }
}

# Create SNAT rule to access the IBM Cloud services over a private network
resource "vcd_nsxv_snat" "rule_ibm_private" {
  edge_gateway = module.ibm_vmware_solutions_shared_instance.edge_gateway_name
  network_type = "ext"
  network_name = module.ibm_vmware_solutions_shared_instance.external_network_name_1

  original_address   = "${vcd_network_routed.tutorial_network_new.gateway}/24"
  translated_address = module.ibm_vmware_solutions_shared_instance.external_network_ips_2
}

# Create vcd App
resource "vcd_vapp" "vmware_satellite_vapp" {
  name = "vmware-satellite-vApp"
}

# Connect org Network to vcpApp
resource "vcd_vapp_org_network" "tutorial_network_new" {
  vapp_name        = vcd_vapp.vmware_satellite_vapp.name
  org_network_name = vcd_network_routed.tutorial_network_new.name
}

# Create VM1
resource "vcd_vapp_vm" "vm_1" {
  vapp_name     = vcd_vapp.vmware_satellite_vapp.name
  name          = "vm-rhel-01"
  catalog_name  = "Public Catalog"
  template_name = "RedHat-7-Template-Official"
  memory        = 8192
  cpus          = 2

  guest_properties = {
    "guest.hostname" = "vm-rhel-01"
  }


  network {
    type               = "org"
    name               = vcd_vapp_org_network.tutorial_network_new.org_network_name
    ip_allocation_mode = "POOL"
    is_primary         = true
  }

  customization {
    auto_generate_password     = false
    admin_password             = "Vmware@1234"
  }
}
# Create VM2
resource "vcd_vapp_vm" "vm_2" {
  vapp_name     = vcd_vapp.vmware_satellite_vapp.name
  name          = "vm-rhel-02"
  catalog_name  = "Public Catalog"
  template_name = "RedHat-7-Template-Official"
  memory        = 8192
  cpus          = 2

  guest_properties = {
    "guest.hostname" = "vm-rhel-02"
  }

  network {
    type               = "org"
    name               = vcd_vapp_org_network.tutorial_network_new.org_network_name
    ip_allocation_mode = "POOL"
    is_primary         = true
  }

  customization {
    auto_generate_password     = false
    admin_password             = "Vmware@1234"
  }
}
# Create VM3
resource "vcd_vapp_vm" "vm_3" {
  vapp_name     = vcd_vapp.vmware_satellite_vapp.name
  name          = "vm-rhel-03"
  catalog_name  = "Public Catalog"
  template_name = "RedHat-7-Template-Official"
  memory        = 8192
  cpus          = 2

  guest_properties = {
    "guest.hostname" = "vm-rhel-03"
  }

  network {
    type               = "org"
    name               = vcd_vapp_org_network.tutorial_network_new.org_network_name
    ip_allocation_mode = "POOL"
    is_primary         = true
  }

  customization {
    auto_generate_password     = false
    admin_password             = "Vmware@1234"
  }
}
# Create VM4
resource "vcd_vapp_vm" "vm_4" {
  vapp_name     = vcd_vapp.vmware_satellite_vapp.name
  name          = "vm-rhel-04"
  catalog_name  = "Public Catalog"
  template_name = "RedHat-7-Template-Official"
  memory        = 8192
  cpus          = 2

  guest_properties = {
    "guest.hostname" = "vm-rhel-04"
  }

  network {
    type               = "org"
    name               = vcd_vapp_org_network.tutorial_network_new.org_network_name
    ip_allocation_mode = "POOL"
    is_primary         = true
  }

  customization {
    auto_generate_password     = false
    admin_password             = "Vmware@1234"
  }
}
# Create VM5
resource "vcd_vapp_vm" "vm_5" {
  vapp_name     = vcd_vapp.vmware_satellite_vapp.name
  name          = "vm-rhel-05"
  catalog_name  = "Public Catalog"
  template_name = "RedHat-7-Template-Official"
  memory        = 8192
  cpus          = 2

  guest_properties = {
    "guest.hostname" = "vm-rhel-05"
  }

  network {
    type               = "org"
    name               = vcd_vapp_org_network.tutorial_network_new.org_network_name
    ip_allocation_mode = "POOL"
    is_primary         = true
  }

  customization {
    auto_generate_password     = false
    admin_password             = "Vmware@1234"

  }
}
# Create VM6
resource "vcd_vapp_vm" "vm_6" {
  vapp_name     = vcd_vapp.vmware_satellite_vapp.name
  name          = "vm-rhel-06"
  catalog_name  = "Public Catalog"
  template_name = "RedHat-7-Template-Official"
  memory        = 8192
  cpus          = 2

  guest_properties = {
    "guest.hostname" = "vm-rhel-06"
  }

  network {
    type               = "org"
    name               = vcd_vapp_org_network.tutorial_network_new.org_network_name
    ip_allocation_mode = "POOL"
    is_primary         = true
  }

  customization {
    auto_generate_password     = false
    admin_password             = "Vmware@1234"

  }
}

resource "null_resource"  "attachhost" {

   count = local.totalVMs


   provisioner "file" {
    source      = "attachHost.sh"
    destination = "/tmp/attachHost.sh"

    connection {
    type     = "ssh"
    user     = "root"
    password = "Vmware@1234"
    host     = "${element(local.publiciplist,count.index)}"
   }
  }
   provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname \"VM${count.index}\"",
      "rpm -ivh http://52.117.132.7/pub/katello-ca-consumer-latest.noarch.rpm",
      "uuid=`uuidgen`",
      "echo '{\"dmi.system.uuid\": \"'$uuid'\"}' > /etc/rhsm/facts/uuid_override.facts",
      "subscription-manager register --org=\"customer\" --activationkey=\"${var.activation_key}\" --force",
      "subscription-manager refresh",
      "subscription-manager repos --enable=*",
      "chmod +x /tmp/attachHost.sh",
      "/tmp/attachHost.sh",
    ]
    connection {
    type     = "ssh"
    user     = "root"
    password = "Vmware@1234"
    host     = "${element(local.publiciplist,count.index)}"
   }
  }
  depends_on = [vcd_vapp_vm.vm_1]
}

