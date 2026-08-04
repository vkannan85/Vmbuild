locals {
  is_linux          = lower(var.os_type) == "linux"
  is_windows        = lower(var.os_type) == "windows"
  has_plan          = var.plan_name != ""
  generate_password = var.admin_password == ""
}

# Auto-generate a strong password when none is supplied (used for Windows,
# or for Linux when disable_password_authentication = false).
resource "random_password" "this" {
  count            = local.generate_password ? 1 : 0
  length           = 20
  special          = true
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

locals {
  admin_password = local.generate_password ? try(random_password.this[0].result, null) : var.admin_password
}

# Accept marketplace legal terms for images that require it (mostly
# third-party / BYOL offers). Not needed for standard first-party images.
resource "azurerm_marketplace_agreement" "this" {
  count     = var.accept_marketplace_terms ? 1 : 0
  publisher = var.image_publisher
  offer     = var.image_offer
  plan      = var.image_sku
}

resource "azurerm_linux_virtual_machine" "this" {
  count = local.is_linux ? 1 : 0

  name                = var.vm_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]
  tags = var.tags

  disable_password_authentication = var.disable_password_authentication
  admin_password                  = var.disable_password_authentication ? null : local.admin_password

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication && var.ssh_public_key != "" ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.ssh_public_key
    }
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  dynamic "plan" {
    for_each = local.has_plan ? [1] : []
    content {
      name      = var.plan_name
      publisher = var.plan_publisher
      product   = var.plan_product
    }
  }

  depends_on = [azurerm_marketplace_agreement.this]
}

resource "azurerm_windows_virtual_machine" "this" {
  count = local.is_windows ? 1 : 0

  name                = var.vm_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = local.admin_password
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]
  tags = var.tags

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  dynamic "plan" {
    for_each = local.has_plan ? [1] : []
    content {
      name      = var.plan_name
      publisher = var.plan_publisher
      product   = var.plan_product
    }
  }

  depends_on = [azurerm_marketplace_agreement.this]
}
