# Vault policy for AAP AppRole - Certificate Lifecycle Management
# Apply with: vault policy write aap-pki policies/aap_pki_policy.hcl

# Issue certificates from the intermediate CA
path "pki_int/issue/server-cert" {
  capabilities = ["create", "update"]
}

# Revoke certificates
path "pki_int/revoke" {
  capabilities = ["create", "update"]
}

# Tidy certificate store (cleanup expired/revoked)
path "pki_int/tidy" {
  capabilities = ["create", "update"]
}

# Read certificate by serial number (for status checks)
path "pki_int/cert/*" {
  capabilities = ["read"]
}

# Read CA chain (for chain validation)
path "pki_int/ca/chain" {
  capabilities = ["read"]
}

# Read CA certificate
path "pki_int/ca" {
  capabilities = ["read"]
}

# Read Tomcat keystore password from KV v2
path "secret/data/tomcat/keystore" {
  capabilities = ["read"]
}
