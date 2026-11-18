locals {
  prefix         = join("-", compact([var.project, var.environment, var.location]))
  prefix_compact = replace(local.prefix, "-", "")

  # Standard tags go last so callers can add tags but cannot override these.
  tags = merge(var.extra_tags, {
    project     = var.project
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
  })
}
