variable "entities" {
  type = map(object({
    metadata = optional(map(string), {})
    policies = optional(list(string), [])
  }))
}

variable "groups" {
  type = map(object({
    type     = optional(string, "internal")
    metadata = optional(map(string), {})
    policies = optional(list(string), [])
    members  = optional(object({
      entities = optional(list(string), [])
      groups   = optional(list(string), [])
    }), {})
  }))
}

variable "aliases" {
  type = object({
    groups   = optional(list(object({ name = string, mount_path = string, alias_name = string })), [])
    entities = optional(list(object({ name = string, mount_path = string, alias_name = string })), [])
  })
  default = { groups = [], entities = [] }
}
