# Certificate Lifecycle Management -- Design Q&A

Captured during design session. Answers inform implementation choices throughout the project.

---

## Vault PKI Configuration

**Q: Which PKI mount path and role name are in use?**
A: Mount `pki_int` (intermediate CA), role `server-cert`. Root CA is on `pki` mount but not directly accessed by automation.

**Q: Is `no_store` enabled on the PKI role?**
A: No -- `no_store=false` (Vault stores issued certificates). This is required for revocation to work; if `no_store=true`, Vault has no record to revoke against.

**Q: What TTL do we target?**
A: Default 1 year (`8760h`). Override via AAP Survey per-job. Renewal threshold at 30 days remaining.

**Q: Do we need IP SANs?**
A: Supported via `vault_cert_ip_sans` variable. Not set by default; used for services addressed by IP.

---

## AAP Integration

**Q: How does AAP authenticate to Vault?**
A: AppRole -- `VAULT_ROLE_ID` and `VAULT_SECRET_ID` injected as AAP Custom Credential Type environment variables. No tokens stored in repo.

**Q: What credential type is used?**
A: Custom credential type "Vault AppRole" with `VAULT_ROLE_ID` and `VAULT_SECRET_ID` as injected environment variables.

**Q: Will the workflow use multiple Job Templates or a single playbook?**
A: POC uses a single playbook (`clm_issue_deploy.yml`) with `block/rescue` for rollback. Production can split into per-stage Job Templates connected in an AAP Workflow Template.

**Q: How are per-run overrides handled?**
A: AAP Survey fields: `target_hosts`, `cert_common_name_override`, `cert_alt_names_override`, `vault_cert_ttl`, `cert_service_type`.

---

## Certificate Deployment

**Q: Which services are in scope?**
A: Nginx (PEM files, graceful reload) and Tomcat (PKCS12 keystore, restart required). Architecture supports adding more via dispatcher pattern.

**Q: Why PKCS12 for Tomcat instead of JKS?**
A: Modern Tomcat (8.5.38+) supports PKCS12 natively. Avoids `keytool` dependency and Java-specific complexity. `community.crypto.openssl_pkcs12` handles conversion.

**Q: How is the Tomcat keystore password managed?**
A: Stored in Vault KV (`secret/data/tomcat/keystore`), fetched at runtime. Never in repo or AAP variables.

**Q: Why `reloaded` for Nginx but `restarted` for Tomcat?**
A: Nginx supports graceful reload (no dropped connections). Tomcat's JVM cannot reload keystores without restart. Both use Ansible handlers triggered by cert file changes.

---

## Backup and Rollback

**Q: Where are backups stored?**
A: On each target host at `/opt/cert_backups/{common_name}/{timestamp}/`. Timestamped dirs with cert, key, and chain files.

**Q: How many backups are retained?**
A: Default 5 (`cert_backup_retain_count`). Oldest pruned automatically.

**Q: Does rollback automatically revoke the failed cert?**
A: No. Rollback restores the previous cert and reloads the service. Revocation is a separate, intentional action via `clm_revoke.yml`. This keeps rollback fast and simple.

---

## Security

**Q: How is private key material protected in logs?**
A: `no_log: true` on every task that handles key material (issuance, deployment, keystore creation). Prevents leakage to AAP job output and Ansible logs.

**Q: What Vault policy does AAP use?**
A: Least-privilege policy (`policies/aap_pki_policy.hcl`): issue certs, revoke certs, tidy CRL, read cert status, read CA chain, read Tomcat keystore password from KV.

**Q: How is `serial: 1` used?**
A: Main deployment playbook processes one host at a time. If cert deploy fails on host 1, host 2 is never touched -- prevents fleet-wide outage from a bad cert or misconfiguration.
