# AAP Workflow Template Configuration Guide

## Custom Credential Type: Vault AppRole

### Input Configuration
```yaml
fields:
  - id: vault_role_id
    type: string
    label: Vault Role ID
  - id: vault_secret_id
    type: string
    label: Vault Secret ID
    secret: true
required:
  - vault_role_id
  - vault_secret_id
```

### Injector Configuration
```yaml
env:
  VAULT_ROLE_ID: "{{ vault_role_id }}"
  VAULT_SECRET_ID: "{{ vault_secret_id }}"
```

## Project Configuration

| Field | Value |
|-------|-------|
| Name | Certificate Lifecycle Management |
| SCM Type | Git |
| SCM URL | (this repository URL) |
| SCM Branch | main |
| SCM Update Options | Clean, Update Revision on Launch |

## Job Templates

One Job Template per workflow-node playbook. These are chained together
in a Workflow Template (next section). Each Job Template passes certificate
data to the next via `set_stats`; the staging directory `/tmp/vault_cert_staging/`
on each target host carries the current cert between nodes.

### CLM - Issue Certificate

| Field | Value |
|-------|-------|
| Name | CLM - Issue Certificate |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/wf_issue.yml |
| Credentials | Vault AppRole |
| Extra Variables | (from Workflow or Survey) |

### CLM - Backup Existing Certificate

| Field | Value |
|-------|-------|
| Name | CLM - Backup Existing |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/wf_backup.yml |
| Credentials | Machine (SSH) |

### CLM - Deploy Certificate

| Field | Value |
|-------|-------|
| Name | CLM - Deploy Certificate |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/wf_deploy.yml |
| Credentials | Machine (SSH) |

### CLM - Verify TLS Handshake

| Field | Value |
|-------|-------|
| Name | CLM - Verify TLS |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/wf_verify.yml |
| Credentials | Machine (SSH) |

### CLM - Rollback (workflow node)

| Field | Value |
|-------|-------|
| Name | CLM - Rollback |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/wf_rollback.yml |
| Credentials | Machine (SSH) |

### CLM - Daily Expiry Check

| Field | Value |
|-------|-------|
| Name | CLM - Daily Expiry Check |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/wf_check_expiry.yml |
| Credentials | Vault AppRole, Machine (SSH) |
| Schedule | Daily at 02:00 |

Queries Vault's Certificates Inventory for expiring leaf certs, builds the
dynamic inventory of renewal targets, and feeds the issue/deploy workflow.

### CLM - Manual Revoke (standalone)

| Field | Value |
|-------|-------|
| Name | CLM - Revoke Certificate |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/clm_revoke.yml |
| Credentials | Vault AppRole |
| Extra Variables | `revoke_serial_number` (from Survey) |

### CLM - Manual Rollback (standalone)

| Field | Value |
|-------|-------|
| Name | CLM - Manual Rollback |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/clm_rollback.yml |
| Credentials | Machine (SSH) |

## Workflow Template: Issue → Deploy → Verify

The end-to-end issuance workflow chains five Job Templates with block/rescue
semantics — `wf_verify` failure triggers `wf_rollback`:

```
[Issue Cert] → (success) → [Backup Existing] → (success) → [Deploy Cert]
                                                                  |
                                                       +----------+----------+
                                                       |                     |
                                                  (success)             (failure)
                                                       |                     |
                                                [Verify TLS]          [Rollback]
                                                       |                     |
                                                  (success)             (success)
                                                       |                     |
                                                [Success Email]    [Verify Rollback]
                                                                         |
                                                                   [Failure Email]
```

Extra Variables set on the Workflow Template cascade to every child Job
Template — only the ones that consume them actually use them (e.g. `vault_pki_role`
is consumed only by `wf_issue.yml`).

## Survey Configuration (Workflow: Issue → Deploy)

| Field | Type | Variable | Default | Required |
|-------|------|----------|---------|----------|
| Target Hosts | Text | `target_hosts` | `all` | Yes |
| Common Name Override | Text | `cert_common_name_override` | (empty) | No |
| Alt Names Override | Text | `cert_alt_names_override` | (empty) | No |
| Certificate TTL | Multiple Choice | `vault_cert_ttl` | `720h` | Yes |
| | | | Choices: `5m`, `720h`, `2160h`, `4380h`, `8760h` | |
| Service Type | Multiple Choice | `cert_service_type` | (empty) | No |
| | | | Choices: `nginx`, `tomcat` | |

## Using the Demo Role (5-minute certs for live demos)

To issue from the `demo-certs` Vault role instead of the default `server-certs`,
override these two Extra Variables when launching the Workflow (tick **Prompt
on launch** on the Extra Variables field so you can toggle this per-run):

```yaml
vault_pki_role: demo-certs
vault_cert_ttl: 5m
```

Vault role constraints for `demo-certs`:

| Setting | Value |
|---------|-------|
| `ttl` | 300s (5 minutes) |
| `max_ttl` | 600s (10 minutes) |

Common TTL choices for demos:

| `vault_cert_ttl` | Effect |
|------------------|--------|
| `5m` | Standard demo |
| `9m` | Edge-of-policy drama (watch the monitor pick it up just before `max_ttl`) |
| `2m`–`3m` | Cert expires during the live presentation — tight but reliable |

Role definitions live in `terraform-vault-tfo-apj-demo-admin/modules/pki/issuing/main.tf`.
The mount path is `issuing-ca` for all four roles (`server-certs`, `client-certs`,
`application-certs`, `demo-certs`), so `vault_pki_mount` doesn't need overriding.

## Survey Configuration (Revoke)

| Field | Type | Variable | Default | Required |
|-------|------|----------|---------|----------|
| Certificate Serial Number | Text | `revoke_serial_number` | (empty) | Yes |

## Notification Templates

Configure email notifications:

| Template | Type | Recipients |
|----------|------|------------|
| CLM Success | Email | ops-team@example.com |
| CLM Failure | Email | ops-team@example.com, security-team@example.com |

Attach to the Workflow Template:
- **Success**: CLM Success notification
- **Failure**: CLM Failure notification

## Schedule Configuration (Daily Expiry Check)

| Field | Value |
|-------|-------|
| Name | Daily Expiry Check |
| Start Date/Time | 02:00 local |
| Repeat Frequency | Every 1 day |
| Job Template | CLM - Daily Expiry Check |
