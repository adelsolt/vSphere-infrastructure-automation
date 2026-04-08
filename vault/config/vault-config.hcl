# storage backend
storage "file" {
  path = "/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true # just while testing
}

api_addr     = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"

ui                = true
default_lease_ttl = "768h"
max_lease_ttl     = "8760h"
