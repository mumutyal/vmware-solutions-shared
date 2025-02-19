output "virtual_machine_access" {
  value = <<VM
  
  ### You can access the vm instance ${vcd_vapp_vm.vm_2.name} using the following SSH command:
      ssh root@${element(local.publiciplist,0)} 
      
      The initial password is: ${vcd_vapp_vm.vm_2.customization[0].admin_password} which you will need to change on first login. 
  ### You can access the vm instance ${vcd_vapp_vm.vm_3.name} using the following SSH command:
      ssh root@${element(local.publiciplist,1)} 
      
      The initial password is: ${vcd_vapp_vm.vm_3.customization[0].admin_password} which you will need to change on first login. 
  ### You can access the vm instance ${vcd_vapp_vm.vm_4.name} using the following SSH command:
      ssh root@${element(local.publiciplist,2)} 
      
      The initial password is: ${vcd_vapp_vm.vm_4.customization[0].admin_password} which you will need to change on first login. 
  VM
}
