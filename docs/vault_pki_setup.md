# Vault PKI Setup Reference

## Prerequisites

- Vault server running and unsealed
- Root CA configured on `pki` mount
- Intermediate CA configured on `pki_int` mount, signed by Root CA

## PKI Role Configuration

Create the PKI role used by automation:

```bash
vault write pki_int/roles/server-cert \
    allowed_domains="example.com" \
    allow_subdomains=true \
    allow_bare_domains=false \
    allow_glob_domains=false \
    allow_ip_sans=true \
    enforce_hostnames=true \
    server_flag=true \
    client_flag=false \
    no_store=false \
    max_ttl="8760h" \
    key_type="rsa" \
    key_bits=2048 \
    key_usage="DigitalSignature,KeyEncipherment" \
    ext_key_usage="ServerAuth" \
    require_cn=true
```

> **Critical**: `no_store=false` is required for revocation. With `no_store=true`, Vault does not retain issued certificates and cannot revoke them.

## AppRole Setup

```bash
# Enable AppRole auth
vault auth enable approle

# Create policy (see policies/aap_pki_policy.hcl)
vault policy write aap-pki policies/aap_pki_policy.hcl

# Create AppRole
vault write auth/approle/role/aap-clm \
    token_policies="aap-pki" \
    token_ttl="1h" \
    token_max_ttl="4h" \
    secret_id_ttl="0" \
    secret_id_num_uses=0

# Get Role ID
vault read auth/approle/role/aap-clm/role-id

# Generate Secret ID
vault write -f auth/approle/role/aap-clm/secret-id
```

## Tomcat Keystore Password (Vault KV)

Store the keystore password in Vault KV for runtime retrieval:

```bash
vault kv put secret/tomcat/keystore password="<secure-password>"
```

## Verify PKI Configuration

```bash
# List roles
vault list pki_int/roles

# Read role config
vault read pki_int/roles/server-cert

# Test issuance (manual)
vault write pki_int/issue/server-cert \
    common_name="test.example.com" \
    ttl="24h"

# Read CA chain
vault read pki_int/ca/chain
```

## CRL and Tidy

```bash
# Check CRL
curl -s $VAULT_ADDR/v1/pki_int/crl | openssl crl -inform DER -noout -text

# Run tidy (cleanup expired/revoked certs)
vault write pki_int/tidy \
    tidy_cert_store=true \
    tidy_revoked_certs=true \
    safety_buffer="72h"
```
