locals {
  cfg            = yamldecode(file(abspath("${path.root}/${var.identities_yaml_path}")))
  _entities_raw  = try(local.cfg.entities, {})
  groups         = try(local.cfg.groups, {})

  # Normalize entities: always have a list "policies" (default [])
  entities = {
    for k, v in local._entities_raw :
    k => merge(v, {
      policies = distinct(try(v.policies, []))
    })
  }

  # Keep your existing alias filter (unchanged)
  entities_with_alias = {
    for k, v in local.entities :
    k => v if length(trimspace(try(v.object_id, ""))) > 0
  }

  internal_groups = {
    for k, v in local.groups :
    k => v if lower(try(v.type, "internal")) == "internal"
  }
  external_groups = {
    for k, v in local.groups :
    k => v if lower(try(v.type, "")) == "external"
  }

  # References declared inside internal groups
  _member_entity_refs = distinct(flatten([
    for gname, g in local.internal_groups : try(g.members.entities, [])
  ]))
  _member_group_refs  = distinct(flatten([
    for gname, g in local.internal_groups : try(g.members.groups, [])
  ]))

  # Split group refs by whether they target internal or external groups
  _member_group_refs_internal = setintersection(toset(local._member_group_refs), toset(keys(local.internal_groups)))
  _member_group_refs_external = setintersection(toset(local._member_group_refs), toset(keys(local.external_groups)))

  _missing_entities = setsubtract(toset(local._member_entity_refs), toset(keys(local.entities)))
  _missing_groups   = setsubtract(toset(local._member_group_refs),   toset(keys(local.groups)))
}

resource "terraform_data" "validate_yaml" {
  lifecycle {
    precondition {
      condition     = length(local._missing_entities) == 0
      error_message = "Unknown entity handle(s) in group members: ${join(", ", tolist(local._missing_entities))}"
    }
    precondition {
      condition     = length(local._missing_groups) == 0
      error_message = "Unknown group name(s) in group members: ${join(", ", tolist(local._missing_groups))}"
    }
    precondition {
      condition     = length(local._member_group_refs_internal) == 0
      error_message = "Internal groups cannot include other internal groups (avoids self-referential planning). Move shared policies to a separate internal group and include both where needed, or convert the included one into an external group aliasing an IdP group."
    }
    precondition {
      condition     = alltrue([
        for k, g in local.external_groups :
        can(regexall("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", trimspace(try(g.alias_object_id, "")))) &&
        length(trimspace(try(g.alias_object_id, ""))) > 0
      ])
      error_message = "Every external group must set a valid AAD Group Object Id (UUID) in alias_object_id."
    }
    precondition {
      condition     = alltrue([
        for k, g in local.external_groups :
        length(keys(try(g.members, {}))) == 0
      ])
      error_message = "External groups must not declare 'members'. Membership comes from the IdP via alias mapping."
    }
    # policies must be a list of non-empty strings for ENTITIES (group policies validated implicitly)
    precondition {
      condition = alltrue([
        for e in values(local.entities) :
        alltrue([for p in e.policies : can(tostring(p)) && length(trimspace(tostring(p))) > 0])
      ])
      error_message = "Each entity 'policies' must be a list of non-empty strings."
    }
  }
}
