# Vault + AAP Certificate Lifecycle Management

Automated X.509 certificate lifecycle management using HashiCorp Vault PKI secrets engine and Ansible Automation Platform.

## Capabilities

- **Issue & Deploy** -- Issue certificates from Vault PKI, deploy to Nginx (PEM) or Tomcat (PKCS12)
- **Monitor** -- Track certificate expiry, flag certificates approaching threshold
- **Renew** -- Automated conditional renewal with backup and rollback
- **Revoke** -- Revoke certificates in Vault by serial number
- **Rollback** -- Restore previous certificate from timestamped backup

## Quick Start

```bash
# Install required collections
ansible-galaxy collection install -r requirements.yml

# Issue and deploy certificates to all hosts
ansible-playbook playbooks/clm_issue_deploy.yml

# Monitor certificate expiry
ansible-playbook playbooks/clm_monitor.yml

# Renew certificates nearing expiry
ansible-playbook playbooks/clm_renew.yml

# Revoke a certificate by serial number
ansible-playbook playbooks/clm_revoke.yml -e revoke_serial_number=<serial>

# Manual rollback to previous backup
ansible-playbook playbooks/clm_rollback.yml
```

## Prerequisites

- Ansible 2.14+
- HashiCorp Vault with PKI secrets engine (Root + Intermediate CA)
- Vault AppRole configured (`VAULT_ROLE_ID` and `VAULT_SECRET_ID` env vars)
- Target hosts with Nginx and/or Tomcat

## Project Structure

```
playbooks/           # Lifecycle playbooks (issue, renew, revoke, monitor, rollback)
roles/               # Modular roles for each lifecycle stage
  vault_cert_issue/  # Issue cert from Vault PKI
  cert_backup/       # Timestamped backup of existing certs
  cert_deploy/       # Deploy with service-specific handling (nginx, tomcat)
  cert_verify/       # Two-stage verification (files + TLS handshake)
  cert_monitor/      # Expiry monitoring
  vault_cert_revoke/ # Certificate revocation
  cert_rollback/     # Restore from backup
inventory/           # Target host inventory
group_vars/          # Per-group variable configuration
policies/            # Vault policy (least-privilege)
docs/                # Architecture, setup guides, design Q&A
```

## Documentation

- [Design Q&A](docs/requirements_qa.md) -- Design decisions and rationale
- [Architecture](docs/architecture.md) -- Component architecture and flow diagrams
- [Vault PKI Setup](docs/vault_pki_setup.md) -- Vault configuration reference
- [AAP Workflow Setup](docs/aap_workflow_setup.md) -- AAP Job/Workflow Template guide
