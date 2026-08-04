output "resource_group_name" {
  description = "Name of the resource group the VM was deployed into."
  value       = azurerm_resource_group.this.name
}

output "vm_id" {
  description = "Resource ID of the deployed VM."
  value       = local.is_linux ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
}

output "vm_name" {
  description = "Name of the deployed VM."
  value       = var.vm_name
}

output "public_ip_address" {
  description = "Public IP address of the VM, if one was allocated."
  value       = var.allocate_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "private_ip_address" {
  description = "Private IP address of the VM's NIC."
  value       = azurerm_network_interface.this.private_ip_address
}

output "admin_username" {
  description = "Admin username configured on the VM."
  value       = var.admin_username
}

output "admin_password" {
  description = "Admin password (only meaningful for Windows, or Linux with password auth enabled). Auto-generated if admin_password was left blank in the parameters file."
  value       = local.admin_password
  sensitive   = true
}
