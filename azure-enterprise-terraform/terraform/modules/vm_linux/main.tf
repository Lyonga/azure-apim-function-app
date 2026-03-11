resource "azurerm_network_interface" "this" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  size                       = var.vm_size
  admin_username             = var.admin_username
  network_interface_ids      = [azurerm_network_interface.this.id]
  allow_extension_operations = false
  tags                       = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  dynamic "identity" {
    for_each = var.identity_type == "None" ? [] : [1]
    content {
      type         = var.identity_type
      identity_ids = contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? var.identity_ids : null
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  lifecycle {
    precondition {
      condition     = !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) || length(var.identity_ids) > 0
      error_message = "identity_ids must contain at least one user-assigned identity when identity_type includes UserAssigned."
    }
  }
}
