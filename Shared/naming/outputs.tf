output "prefix" {
  value       = local.prefix
  description = "Name prefix, e.g. sepf-dev-use1"
}

output "prefix_compact" {
  value       = local.prefix_compact
  description = "Prefix without hyphens, for resources like Azure storage accounts"
}

output "tags" {
  value       = local.tags
  description = "Standard tag map to apply to resources"
}
