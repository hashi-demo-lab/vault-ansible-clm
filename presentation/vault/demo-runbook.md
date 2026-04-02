# Demo Runbook — Certificate Lifecycle Management
## HashiCorp Vault + Red Hat AAP + HCP Certificates Inventory

**Total demo time:** 8–10 minutes (after slides, not during)
**When to demo:** After Slide 5 (The Complete Lifecycle) or Slide 9 (Close the Gap) depending on audience energy. If the room is engaged, do it at the end as the "this page is the product" payoff. If energy is dipping at Slide 5, break into the demo to re-anchor with something real.

---

## Demo Philosophy

**Show the outcome, not the code.** The audience cares that it works, not how the YAML is structured. Every screen you show must answer one question: *"What just happened and why should I care?"*

Three screens. Three stories. That's it.

| Screen | What You Show | What It Proves | Time |
|--------|--------------|----------------|------|
| HCP Certificates Inventory | The dashboard | "We know every certificate, its status, and when it expires" | 2 min |
| AAP Workflow Visualizer | The workflow running | "One click renews, deploys, and verifies — with automatic rollback" | 4 min |
| Browser certificate viewer | The cert in the padlock | "The certificate on this page was just issued by the system we described" | 2 min |

---

## Pre-Demo Setup (do this 30 minutes before)

1. **Ensure certs are near expiry** — Either use real certs approaching renewal, or set `cert_expiry_threshold_days=31` in the daily workflow survey to force detection
2. **Open three browser tabs, ready to switch:**
   - Tab 1: HCP Portal — Certificates Inventory (filtered to `LEAF` certs, show columns: Common Name, Status, Role, Valid Until, Issuer, Serial Number, Revoked At)
   - Tab 2: AAP — Workflow Templates page (have "CLM - Daily Renewal Check" visible)
   - Tab 3: `https://web-server-01.hashicorp.local/` — the landing page itself
3. **Clear the CLM Renewal Targets inventory** — You want it empty so the audience sees it populate live

---

## Demo Script

### Act 1: "Where are we today?" (2 minutes)
**Screen: HCP Certificates Inventory**

> "Before we automate anything, we need visibility. This is HCP Vault's Certificates Inventory — every certificate issued by our PKI engine, in one place."

**What to point out (don't read everything — pick what's relevant to the room):**
- The three active certs for web-server-01/02/03 — "These are the live certificates on our web servers right now"
- The `Valid Until` column — "30-day lifetime. In the 47-day world, this is what every cert looks like"
- The `Role` column — "server-certs — Vault enforced the policy. Nobody manually chose the key type or TTL"
- Any revoked certs visible — "These were from a previous rotation. Revoked automatically when we deployed new ones. Notice the `Revoked At` timestamp — full audit trail"

**Transition:**
> "So we can see them. Now the question is: what happens when they're about to expire? Let me show you."

---

### Act 2: "Watch it work" (4 minutes)
**Screen: AAP Workflow Visualizer**

This is the centrepiece. The workflow visualizer is visually striking and tells the story without you needing to explain plumbing.

**Step 1: Launch the Daily Renewal Check workflow**

> "This is our daily renewal workflow. Two stages. Stage one queries the Certificates Inventory we just looked at, finds any certificate expiring within our threshold, and populates a target list. Stage two takes that list and runs the full lifecycle — issue, backup, deploy, verify."

- Click **Launch** on "CLM - Daily Renewal Check"
- Set `cert_expiry_threshold_days` to `31` (so it catches the 30-day certs)
- **As it runs, narrate what's happening:**

> "It's authenticating to HCP, querying the inventory API... it found our three web servers. Now it's populating the renewal inventory — only hosts that actually need renewal."

**Step 2: Watch the inner workflow execute**

When the CLM workflow kicks off, the visualizer shows the node chain:

```
[Issue] → [Backup] → [Deploy] → [Verify]
                        ↓ (failure)
                    [Rollback]
```

> "Issue — a new certificate is being generated from Vault's PKI engine right now. 30-day lifetime, EC P-256 key, server auth only. Vault enforced all of that."

> "Backup — the existing certificate is preserved. Timestamped. If anything goes wrong, we have a way back."

> "Deploy — the new cert is on the server. Nginx just reloaded."

> "Verify — we're confirming the TLS handshake. Not just that the file is there — that the service is actually serving it."

**Point to the rollback node sitting grey/unused:**
> "See that rollback node? It didn't fire. That's the happy path. But if verify had failed — bad cert, wrong CN, service didn't reload — that node lights up automatically. Restores the backup, reloads, re-verifies. No human needed."

**Transition:**
> "That's the workflow. Let me show you the result."

---

### Act 3: "The proof is in the padlock" (2 minutes)
**Screen: Browser — web-server-01.hashicorp.local**

> "This is the page we've been presenting from."

- Click the **padlock icon** in the browser address bar
- Open the certificate details
- **Point out:**
  - **Issued to:** `web-server-01.hashicorp.local`
  - **Issued by:** `GCVE Issuing CA` — "That's our Vault PKI issuing CA"
  - **Valid from / to:** Show the 30-day window — "Issued minutes ago by the workflow we just watched"
  - **Key type:** ECDSA P-256 — "Policy-enforced. Nobody chose this manually"

> "This certificate was issued by Vault, deployed by Ansible, verified by a TLS handshake, and it's serving this page right now. The system you just saw built — that's what's running underneath this presentation."

*Pause. Let that land.*

---

## If Something Goes Wrong

| Scenario | What to Do |
|----------|-----------|
| Workflow fails at Issue | Vault token likely expired. Say: "This is actually a great example — the workflow stops, nothing gets half-deployed, and we'd get an alert. Let me show the error." Show the failed node. |
| Workflow fails at Deploy | Say: "Watch what happens next." The rollback node should fire. This is actually a *better* demo. |
| Certs Inventory is empty | The scan hasn't run yet. Say: "The inventory scans periodically — let me show you what it looks like with data" and use a screenshot you prepared. |
| Browser shows old cert | Hard refresh (Ctrl+Shift+R). If still old, the deploy may not have flushed nginx. This is a talking point: "In production, you'd have health checks catching this." |

---

## What NOT To Show

- **Code / YAML** — Resist the urge. The moment you show a playbook, half the room tunes out and the other half starts reading line by line. If someone asks, say "Happy to walk through the code in a follow-up" or show the architecture slide (Chapter 6) which has the right level of detail.
- **Terminal output** — Same problem. Scrolling green text is impressive to engineers and meaningless to everyone else.
- **Vault UI** — The Certificates Inventory in HCP is the right abstraction. Don't drop into the Vault secrets engine UI — it's too low-level for this audience.
- **AAP job template configuration** — The workflow visualizer is the hero. Don't show the job template edit page, surveys, or credential config.

**Exception:** If the audience is purely technical (all engineers, no leadership), you can show one code snippet. Make it the `wf_check_expiry.yml` playbook's filter logic — it's the most impressive in the fewest lines:

```yaml
# Find certs expiring within threshold
_expiring_certs: >-
  {{ _cert_inventory.json.data
     | selectattr('certificate_type', 'equalto', 'CERTIFICATE_TYPE_LEAF')
     | selectattr('revoked_at', 'none')
     | selectattr('not_after', 'lt', _expiry_cutoff)
     | list }}
```

> "Four lines. That's the entire detection logic. Query the inventory, filter to leaf certs, exclude revoked, find anything expiring before our threshold. The rest is just plumbing."

---

## Audience-Specific Emphasis

| Audience | Emphasize | De-emphasize |
|----------|-----------|-------------|
| **CISO / Security** | Certificates Inventory (visibility), revocation audit trail, policy enforcement | Workflow mechanics, deployment details |
| **Platform / Ops** | Workflow Visualizer (automation), rollback, zero-touch renewal | Certificate policy, compliance talk |
| **Leadership / CxO** | The browser cert (tangible proof), the "this page is the product" moment, outcomes slide numbers | Everything technical — stay at the outcome level |
| **Mixed** | All three acts, equal weight. Let the Certificates Inventory speak to security, the workflow to ops, and the browser cert to leadership. |

---

## The Mic Drop

After showing the certificate in the browser, transition back to the slides (Slide 9 — Close the Gap):

> "You've been looking at the product the entire time. This page. This certificate. This workflow. It's not a mock-up. It's not a lab. It's running right now, on infrastructure we built together with Vault and AAP."

> "Three steps to get here yourself: See it live — you just did. Prove it in your environment. Scale it to your fleet."

Then stop talking. Don't summarise. Don't say "any questions." Let the silence do the work.
