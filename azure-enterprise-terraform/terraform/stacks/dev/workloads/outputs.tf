output "vm_private_ip" {
  value = try(module.vm[0].private_ip, null)
}
output "public_ip" {
  value = try(module.pip[0].ip_address, null)
}
