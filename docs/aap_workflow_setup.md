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

### CLM Issue and Deploy (POC -- single playbook with block/rescue)

| Field | Value |
|-------|-------|
| Name | CLM - Issue and Deploy Certificate |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/clm_issue_deploy.yml |
| Credentials | Vault AppRole, Machine (SSH) |
| Extra Variables | (from Survey) |
| Verbosity | 0 - Normal |

### CLM Renewal Check

| Field | Value |
|-------|-------|
| Name | CLM - Renewal Check |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/clm_renew.yml |
| Credentials | Vault AppRole, Machine (SSH) |
| Schedule | Daily at 02:00 |

### CLM Monitor Only

| Field | Value |
|-------|-------|
| Name | CLM - Monitor Expiry |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/clm_monitor.yml |
| Credentials | Machine (SSH) |

### CLM Revoke

| Field | Value |
|-------|-------|
| Name | CLM - Revoke Certificate |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/clm_revoke.yml |
| Credentials | Vault AppRole |
| Extra Variables | `revoke_serial_number` (from Survey) |

### CLM Rollback

| Field | Value |
|-------|-------|
| Name | CLM - Manual Rollback |
| Inventory | CLM Hosts |
| Project | Certificate Lifecycle Management |
| Playbook | playbooks/clm_rollback.yml |
| Credentials | Machine (SSH) |

## Survey Configuration (Issue and Deploy)

| Field | Type | Variable | Default | Required |
|-------|------|----------|---------|----------|
| Target Hosts | Text | `target_hosts` | `all` | Yes |
| Common Name Override | Text | `cert_common_name_override` | (empty) | No |
| Alt Names Override | Text | `cert_alt_names_override` | (empty) | No |
| Certificate TTL | Multiple Choice | `vault_cert_ttl` | `8760h` | Yes |
| | | | Choices: `720h`, `2160h`, `4380h`, `8760h` | |
| Service Type | Multiple Choice | `cert_service_type` | (empty) | No |
| | | | Choices: `nginx`, `tomcat` | |

## Survey Configuration (Revoke)

| Field | Type | Variable | Default | Required |
|-------|------|----------|---------|----------|
| Certificate Serial Number | Text | `revoke_serial_number` | (empty) | Yes |

## Workflow Template (Production)

For production, split into per-stage Job Templates connected in AAP Workflow:

```
[Issue Cert] → (success) → [Backup Existing] → (success) → [Deploy Cert]
                                                                  |
                                                       +----------+----------+
                                                       |                     |
                                                  (success)             (failure)
                                                       |                     |
                                                [Verify Cert]          [Rollback]
                                                       |                     |
                                                  (success)             (success)
                                                       |                     |
                                                [Success Email]    [Verify Rollback]
                                                                         |
                                                                   [Failure Email]
```

> **Note**: Production workflow requires `set_stats` module in each playbook to pass variables (cert data, serial number, backup path) between Job Template nodes. The POC avoids this complexity by handling everything in a single playbook.

## Notification Templates

Configure email notifications:

| Template | Type | Recipients |
|----------|------|------------|
| CLM Success | Email | ops-team@example.com |
| CLM Failure | Email | ops-team@example.com, security-team@example.com |

Attach to Job Template:
- **Success**: CLM Success notification
- **Failure**: CLM Failure notification

## Schedule Configuration (Renewal)

| Field | Value |
|-------|-------|
| Name | Daily Renewal Check |
| Start Date/Time | 02:00 local |
| Repeat Frequency | Every 1 day |
| Job Template | CLM - Renewal Check |
