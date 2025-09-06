## Other secret engines being researched


### Default database secrets engine
path "database/*" 
{
   capabilities = [ "create", "read", "update", "delete", "list"]
}


### Consul secrets engine
path "consul/*" 
{
   capabilities = [ "create", "read", "update", "delete", "list"]
}


### Nomad secrets engine
path "nomad/*" 
{
   capabilities = [ "create", "read", "update", "delete", "list"]
}