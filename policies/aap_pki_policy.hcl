# Vault policy for AAP AppRole - Certificate Lifecycle Management
# Apply with: vault policy write aap-pki policies/aap_pki_policy.hcl

# Issue certificates from the intermediate CA
path "pki/issue/server" {
  capabilities = ["create", "update"]
}

# Revoke certificates
path "pki/revoke" {
  capabilities = ["create", "update"]
}

# Tidy certificate store (cleanup expired/revoked)
path "pki/tidy" {
  capabilities = ["create", "update"]
}

# Read certificate by serial number (for status checks)
path "pki/cert/*" {
  capabilities = ["read"]
}

# Read CA chain (for chain validation)
path "pki/ca/chain" {
  capabilities = ["read"]
}

# Read CA certificate
path "pki/ca" {
  capabilities = ["read"]
}

# Read Tomcat keystore password from KV v2
path "secret/data/tomcat/keystore" {
  capabilities = ["read"]
}
