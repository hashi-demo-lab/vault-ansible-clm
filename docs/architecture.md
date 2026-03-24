# Certificate Lifecycle Management -- Architecture

## Overview

This project automates X.509 certificate lifecycle management using HashiCorp Vault (PKI secrets engine) for certificate issuance and Ansible Automation Platform (AAP) for orchestrated deployment, verification, and remediation.

## Component Architecture

```mermaid
graph TD
    AAP[AAP Controller] -->|AppRole Auth| Vault[HashiCorp Vault]
    Vault -->|PKI Secrets Engine| PKI[Intermediate CA - pki_int]
    PKI -->|Issue Certificate| Cert[X.509 Certificate + Key]
    AAP -->|Deploy via SSH| Nginx[Nginx Hosts]
    AAP -->|Deploy via SSH| Tomcat[Tomcat Hosts]
    Nginx -->|PEM files| NginxSSL[Nginx SSL Config]
    Tomcat -->|PKCS12 keystore| TomcatSSL[Tomcat SSL Connector]
```

## Certificate Issuance Flow

```mermaid
sequenceDiagram
    participant AAP as AAP Controller
    participant Vault as Vault Server
    participant Target as Target Host

    AAP->>Vault: Authenticate (AppRole)
    Vault-->>AAP: Client Token
    AAP->>Vault: POST pki_int/issue/server-cert
    Vault-->>AAP: Certificate + Key + CA Chain
    AAP->>Target: Backup existing cert
    AAP->>Target: Deploy new cert/key/chain
    AAP->>Target: Reload/restart service
    AAP->>Target: Verify TLS handshake
```

## Deployment with Rollback

```mermaid
flowchart TD
    A[Issue Certificate] --> B[Backup Existing]
    B --> C[Deploy Certificate]
    C --> D{Verify TLS}
    D -->|Pass| E[Success]
    D -->|Fail| F[Rollback from Backup]
    F --> G[Verify Rollback]
    G --> H[Report Failure]
    C -->|Error| F
```

## Role Dependency Map

| Role | Purpose | Dependencies |
|------|---------|-------------|
| `vault_cert_issue` | Issue cert from Vault PKI | `community.hashi_vault` |
| `cert_backup` | Timestamped backup of existing certs | `community.crypto` |
| `cert_deploy` | Deploy cert + service-specific config | `community.crypto` (Tomcat PKCS12) |
| `cert_verify` | File checks + TLS handshake validation | `community.crypto` |
| `cert_monitor` | Read cert expiry, set renewal fact | `community.crypto` |
| `vault_cert_revoke` | Revoke cert by serial number | `community.hashi_vault` |
| `cert_rollback` | Restore from latest backup | `community.crypto` (Tomcat PKCS12) |

## Dispatcher Pattern (cert_deploy)

The `cert_deploy` role uses a dispatcher pattern for extensibility:

```
cert_deploy/tasks/main.yml          # Common: write cert/key/chain files
  └── deploy_{{ cert_service_type }}.yml
      ├── deploy_nginx.yml           # Nginx: fullchain, config test, reload
      └── deploy_tomcat.yml          # Tomcat: PEM->PKCS12, restart
```

Adding a new service type (e.g., Apache httpd):
1. Create `roles/cert_deploy/tasks/deploy_httpd.yml`
2. Create `group_vars/httpd.yml`
3. Add `httpd` group to `inventory/hosts.yml`

No changes needed to `main.yml` or existing service deploy files.

## Security Model

- **Authentication**: AAP to Vault via AppRole (role ID + secret ID as env vars)
- **Authorization**: Least-privilege Vault policy (`policies/aap_pki_policy.hcl`)
- **Secrets in transit**: `no_log: true` on all key-handling tasks
- **Secrets at rest**: Keystore passwords in Vault KV, not in repo
- **Blast radius**: `serial: 1` limits deployment to one host at a time
