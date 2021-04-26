variable "vcd_user" {
  description = "vCloud Director username."
  default = "admin"
}

variable "vcd_password" {
  description = "vCloud Director instance password."
  default = ""
}

variable "vcd_org" {
  description = "vCloud Director organization name/id."
  default = ""
}

variable "vcd_url" {
  description = "vCloud Director url."
  default = "https://daldir01.vmware-solutions.cloud.ibm.com/api"
}

variable "vdc_name" {
  description = "vCloud Director virtual datacenter."
  default = ""
}

variable "vdc_edge_gateway_name" {
  description = "vCloud Director virtual datacenter edge gateway name."
  default = ""
}

variable "VM_Public_ips" {
  description = "Enter the List of public ips form datacenter: ip1,ip2,ip3. Mandatory"
}

variable "allow_ssh" {
  description = "Set to false to not configure SSH into the VM."
  default = true
}
