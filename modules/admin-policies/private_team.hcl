# Team secrets - only accessible by team members
# Uses Identity > Group names (case-sensitive)

# Course Production (Identity > Group > course-production)
path "private-team/+/{{identity.groups.ids.d483aaa7-8624-705c-76d2-a23d743614d5.name}}" {
  capabilities = ["list"]
}
path "private-team/+/{{identity.groups.ids.d483aaa7-8624-705c-76d2-a23d743614d5.name}}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# For Web UI usage
path "private-team/metadata" { capabilities = ["list"] }
path "identity/group/id"     { capabilities = ["list"] }


