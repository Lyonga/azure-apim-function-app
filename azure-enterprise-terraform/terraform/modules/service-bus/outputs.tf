output "id" {
  value       = azurerm_servicebus_namespace.this.id
  description = "Namespace id."
}

output "name" {
  value       = azurerm_servicebus_namespace.this.name
  description = "Namespace name."
}

output "queues" {
  value       = keys(azurerm_servicebus_queue.this)
  description = "Queue names."
}

output "topics" {
  value       = keys(azurerm_servicebus_topic.this)
  description = "Topic names."
}
