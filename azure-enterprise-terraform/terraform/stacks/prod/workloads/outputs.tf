output "vm_private_ip" {
  value = try(module.vm[0].private_ip, null)
}
