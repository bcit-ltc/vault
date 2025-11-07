locals {
  root         = yamldecode(var.identities_yaml)
  internal_map = try(local.root.groups.internal, local.root.groups)

  team_groups = {
    for name, g in local.internal_map :
    name => g
    if try(g.metadata.id, "") != ""
  }
}

# Per-team policy: ${mount}/<group-name>/**
resource "vault_policy" "team_private" {
  for_each = local.team_groups
  name     = "team-private-${each.key}"

  policy = <<-EOT
    # --- Browsing (KV v2 metadata) ---
    # list the team folder
    path "${var.mount}/metadata/{{identity.groups.ids.${each.value.metadata.id}.name}}" {
      capabilities = ["list"]
    }
    # list/read entries under the team folder (UI needs this)
    path "${var.mount}/metadata/{{identity.groups.ids.${each.value.metadata.id}.name}}/*" {
      capabilities = ["list", "read"]
    }

    # --- CRUD on secret data (KV v2 data) ---
    path "${var.mount}/data/{{identity.groups.ids.${each.value.metadata.id}.name}}/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }

    # --- KV v2 lifecycle ops ---
    path "${var.mount}/delete/{{identity.groups.ids.${each.value.metadata.id}.name}}/*"   { capabilities = ["update"] }
    path "${var.mount}/undelete/{{identity.groups.ids.${each.value.metadata.id}.name}}/*" { capabilities = ["update"] }
    path "${var.mount}/destroy/{{identity.groups.ids.${each.value.metadata.id}.name}}/*"  { capabilities = ["update"] }
  EOT
}

# Seed a simple placeholder secret per team so access is immediately testable
resource "vault_kv_secret_v2" "team_placeholder" {
  for_each = local.team_groups

  mount = var.mount
  name  = "${each.key}/__created_by_terraform"

  data_json = jsonencode({
    note        = "Seeded by Terraform so your team can verify access."
    created_by  = "terraform"
    instructions = "Add your team secrets under this folder."
  })

  # ignore out-of-band edits
  lifecycle {
    ignore_changes = [data_json]
  }
}

# ---- Allow global listing of top-level team folders in the UI ----

# Policy: list team folders at the root of the mount
resource "vault_policy" "private_team" {
  name   = "private-team"
  policy = <<-EOT
    # Let users list the top-level keys (team names) under the mount
    path "${var.mount}/metadata" { capabilities = ["list"] }
  EOT
}
