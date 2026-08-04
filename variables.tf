############################################
# Subscription / General
############################################

variable "subscription_id" {
  description = "Azure subscription ID to deploy into. Leave null to use the CLI-logged-in default (az login) or ARM_SUBSCRIPTION_ID env var."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Name of the resource group that will hold the VM and its resources."
  type        = string
}

variable "location" {
  description = "Azure region to deploy into, e.g. \"eastus\", \"westeurope\"."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}

############################################
# VM identity / sizing
############################################

variable "vm_name" {
  description = "Name of the virtual machine."
  type        = string
}

variable "vm_size" {
  description = "Azure VM size / SKU, e.g. \"Standard_B2s\", \"Standard_D2s_v5\"."
  type        = string
  default     = "Standard_B2s"
}

variable "os_type" {
  description = "Operating system family of the VM image: \"linux\" or \"windows\"."
  type        = string
  default     = "linux"

  validation {
    condition     = contains(["linux", "windows"], lower(var.os_type))
    error_message = "os_type must be either \"linux\" or \"windows\"."
  }
}

############################################
# Marketplace image
############################################

variable "image_publisher" {
  description = "Marketplace image publisher, e.g. \"Canonical\"."
  type        = string
}

variable "image_offer" {
  description = "Marketplace image offer, e.g. \"0001-com-ubuntu-server-jammy\"."
  type        = string
}

variable "image_sku" {
  description = "Marketplace image SKU, e.g. \"22_04-lts-gen2\"."
  type        = string
}

variable "image_version" {
  description = "Marketplace image version. Use \"latest\" unless you need to pin a specific version."
  type        = string
  default     = "latest"
}

variable "accept_marketplace_terms" {
  description = "Set true if the chosen image requires accepting marketplace legal terms before it can be deployed (most third-party/BYOL images). Not needed for standard first-party images like Canonical Ubuntu."
  type        = bool
  default     = false
}

variable "plan_name" {
  description = "Marketplace plan name (only required for images that need a 'plan' block — usually matches image_sku). Leave empty for standard images."
  type        = string
  default     = ""
}

variable "plan_publisher" {
  description = "Marketplace plan publisher (only required alongside plan_name). Leave empty for standard images."
  type        = string
  default     = ""
}

variable "plan_product" {
  description = "Marketplace plan product/offer (only required alongside plan_name). Leave empty for standard images."
  type        = string
  default     = ""
}

############################################
# OS disk
############################################

variable "os_disk_caching" {
  description = "OS disk caching mode."
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "OS disk managed disk type, e.g. \"Standard_LRS\", \"StandardSSD_LRS\", \"Premium_LRS\"."
  type        = string
  default     = "StandardSSD_LRS"
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB. Leave null to use the image's default size."
  type        = number
  default     = null
}

############################################
# Authentication
############################################

variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Admin password for the VM. Required for Windows, and for Linux when disable_password_authentication = false. Leave empty to auto-generate a random password (see output admin_password)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "disable_password_authentication" {
  description = "Linux only: disable password auth and require the SSH key in ssh_public_key. Ignored for Windows."
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "Linux only: SSH public key content (e.g. contents of ~/.ssh/id_rsa.pub). Required when disable_password_authentication = true."
  type        = string
  default     = ""
}

############################################
# Networking
############################################

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Address prefix for the VM subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "allocate_public_ip" {
  description = "Whether to create and attach a public IP to the VM's NIC."
  type        = bool
  default     = true
}

variable "public_ip_allocation_method" {
  description = "Public IP allocation method: \"Static\" or \"Dynamic\"."
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "Public IP SKU: \"Basic\" or \"Standard\"."
  type        = string
  default     = "Standard"
}

variable "open_inbound_ports" {
  description = "List of inbound TCP ports to allow from open_inbound_source_ranges (e.g. [22] for SSH, [3389] for RDP)."
  type        = list(number)
  default     = [22]
}

variable "open_inbound_source_ranges" {
  description = "CIDR ranges allowed to reach open_inbound_ports. Restrict this to your own IP/office range in production instead of 0.0.0.0/0."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
