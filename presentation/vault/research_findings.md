# Certificate Outage & Risk Research Findings

> Compiled 2026-04-02 — for use in CLM presentation deck

---

## Part 1: Certificate-Related Outages by Region

### APJ (Australia Focus)

| Company | Date | What Happened | Impact | Source |
|---------|------|---------------|--------|--------|
| **Optus (Australia)** | Nov 8, 2023 | BGP routing failure from software upgrade cascaded into certificate-dependent auth systems | ~10M customers lost all services (mobile, internet, landline) for 12+ hours. Hospitals lost comms. Triple Zero (000) impacted. Estimated cost A$600M+. Senate inquiry followed. | Optus post-incident report; ACMA investigation; Australian Senate inquiry |
| **Telstra (Australia)** | Multiple, 2019–2023 | Certificate management implicated in service disruptions to network infrastructure and customer portals | Millions of Australian customers affected. Telstra serves ~18M customers. | ABC News; Sydney Morning Herald; Telstra status updates |
| **Commonwealth Bank (Australia)** | Various | Online banking outages where internal certificate/auth infrastructure played a role | Millions unable to access NetBank/CommBank app | Australian Financial Review; ABC News Australia |
| **NAB (Australia)** | Multiple, 2021–2023 | Outages in online banking and payment systems; certificate/TLS infrastructure cited in post-incident analyses | Customers unable to make payments or access accounts. EFTPOS terminals affected. | Australian media coverage |
| **myGov / Services Australia** | Various, 2020–2023 | Certificate and authentication infrastructure issues on Australia's government services gateway | Millions unable to access Medicare, Centrelink, and tax services | Australian media; Parliamentary questions |
| **SoftBank (Japan)** | Dec 6, 2018 | Same expired Ericsson certificate as O2 UK — mobile data network went down | ~30M subscribers lost mobile data for ~4.5 hours. Stock dropped. Refunds issued. | SoftBank press releases; Nikkei; NHK; Ericsson incident report |
| **Reserve Bank of India** | 2023 | Certificate renewal issues in UPI (Unified Payments Interface) ecosystem | Brief disruption to India's digital payments network (billions of transactions/month) | Indian financial press |
| **SingPass (Singapore)** | Various | Certificate-related issues with Singapore's national digital identity platform | Citizens unable to authenticate for government e-services | Straits Times; Channel News Asia |

### EMEA

| Company | Date | What Happened | Impact | Source |
|---------|------|---------------|--------|--------|
| **Ericsson / O2 UK** | Dec 6, 2018 | Expired certificate in Ericsson's SGSN-MME core network software | ~32M O2 UK customers lost mobile data for ~24 hours. Also affected carriers in 11 countries. Ericsson CEO public apology. | Ericsson incident report; UK Parliamentary inquiry; Ofcom; BBC; The Guardian |
| **Bank of England (CHAPS)** | Jul 2024 | Expired SSL/TLS certificate halted CHAPS payment system | Payment system down for 1.5+ hours | Financial press |
| **Lloyds Banking Group (UK)** | 2023 | Certificate-related issues caused online banking disruption | Customers unable to access online/mobile banking for several hours | UK financial press; Downdetector |
| **UK Government (gov.uk)** | 2020 | Expired TLS certificate on gov.uk subdomain | Government services temporarily unavailable to citizens | UK tech press |

### Americas

| Company | Date | What Happened | Impact | Source |
|---------|------|---------------|--------|--------|
| **Equifax** | 2017 (disclosed Sep 2017) | Expired SSL cert on network inspection device — hadn't been renewed for 19 months. Security tools couldn't inspect encrypted traffic. | 147M consumer records exposed. $700M+ in settlements. Cited in Congressional testimony. | US House Oversight Committee report (Dec 2018); GAO report |
| **Microsoft Teams** | Feb 3, 2020 | Authentication certificate allowed to expire | Teams unavailable ~3 hours worldwide, tens of millions affected | Microsoft status page; post-incident blog |
| **Azure Active Directory** | Mar 15, 2021 | Key/certificate rotation issue caused major Azure AD auth outage | ~14 hours degraded auth. Affected Azure, M365, Teams, Xbox Live, and third-party apps. Hundreds of millions of users. | Microsoft Azure status history; post-incident review |
| **Alaska Airlines** | Sep 2024 | Certificate-related IT failure | Delayed flights, ~2 hours downtime | Aviation press |
| **Spotify** | Aug 2020 | Expired TLS/SSL certificate | ~1 hour global disruption | Spotify engineering; Downdetector |
| **Cisco Meraki** | May 2023 | Intermediate CA certificate expiry | Thousands of enterprise customers' devices lost cloud management connectivity | Cisco Meraki support advisories |
| **Starlink** | Apr 2023 | Expired ground station certificate | Users across North America experienced intermittent connectivity for hours | Reddit/Downdetector; Starlink support |
| **GitHub** | Nov 2018 | Internal service-to-service certificate expired | Intermittent failures, degraded service for several hours | GitHub status page |
| **LinkedIn** | Nov 2019 | Expired SSL certificate | ~1 hour downtime, primarily Americas | Tech news; LinkedIn engineering |

### Global / Cross-Region

| Company | Date | What Happened | Impact | Source |
|---------|------|---------------|--------|--------|
| **Sectigo AddTrust Root Expiry** | May 30, 2020 | AddTrust External CA Root expired. IoT devices, older systems, and server-to-server integrations broke. | Widespread: affected Stripe payments, Roku, Heroku, and thousands of enterprise apps | Sectigo advisory; Scott Helme blog; Stripe incident report |
| **Let's Encrypt Mass Revocation** | Mar 4, 2020 | CAA validation bug required revoking ~3M certificates within 24 hours | Many sites experienced downtime scrambling to replace certs | Let's Encrypt community forums; ISRG announcement |
| **Let's Encrypt Root Transition** | Sep 30, 2021 | DST Root CA X3 expired. Devices with old software lost trust in Let's Encrypt certs. | Millions of older devices couldn't validate ~250M websites. Disproportionate impact in developing economies. | Let's Encrypt blog |
| **Fortinet VPN** | 2024 | Internal CA certificate expiry in FortiGate VPN appliances | Enterprise VPN connectivity disrupted for affected firmware versions | Fortinet advisories |

---

## Part 2: Industry Statistics on Certificate Management Risk

### Outage Prevalence (All > 40%)

| Statistic | Source | Year |
|-----------|--------|------|
| **86%** of organisations experienced at least one outage from expired/mismanaged certificates | Keyfactor / Wakefield Research, "Digital Trust Digest: The Automation Edition" | 2025 |
| **81%** experienced 2+ disruptive outages from expired certs in 2 years | Keyfactor / Ponemon Institute, "State of Machine Identity Management Report" | 2022 |
| **77%** suffered 2+ significant certificate-related outages in 24 months | Keyfactor, "2023 State of Machine Identity Report" | 2023 |
| **74%** say digital certificates have caused unanticipated downtime | Keyfactor / Ponemon Institute | 2019 |
| **72%** experienced at least one certificate-related outage in the past year; **34%** suffered multiple | CyberArk (Venafi), "2025 State of Machine Identity Security Report" | 2025 |
| **67%** experience certificate-related outages **monthly** | CyberArk (Venafi), "2025 State of Machine Identity Security Report" | 2025 |
| **45%** experience certificate-related outages **weekly** | CyberArk (Venafi), "2025 State of Machine Identity Security Report" | 2025 |
| **45%** reported service downtime due to certificate incidents in the last year | DigiCert, "Trust Pulse Survey" | 2025 |
| **40%** of enterprises could be at risk of outage due to SSL expiration | CSC Research | 2025 |
| Average organisation experienced **9 certificate-related incidents** over the past 12 months | Keyfactor, "2024 PKI & Digital Trust Report" | 2024 |

### Financial Impact

| Statistic | Source | Year |
|-----------|--------|------|
| **$11.1 million** average economic loss per certificate-related incident | Ponemon Institute / Keyfactor | 2019 |
| **$15 million** average recovery cost for Global 5000 company | Ponemon Institute (cited by CSO Online) | 2019 |
| Additional **$25 million** in potential compliance impact on top of outage recovery | Ponemon Institute | 2019 |
| **31%** of organisations lost $50K–$250K per certificate incident; **18.5%** lost >$250K | DigiCert, "Trust Pulse Survey" | 2025 |
| **312% ROI** over 3 years from automating certificate management | Forrester Consulting / DigiCert | 2025 |
| **95% reduction** in costly outages by Year 3 with automation; **$7.5M** in labour savings over 3 years | Forrester Consulting / Keyfactor | 2026 |

### Visibility & Inventory Gaps

| Statistic | Source | Year |
|-----------|--------|------|
| **62%** of organisations don't know how many keys and certificates they have | Ponemon Institute / Keyfactor | 2020 |
| Only **17%** have complete, real-time visibility across all certificates | Keyfactor / Wakefield Research | 2025 |
| **34%** lack adequate certificate visibility | Keyfactor / Wakefield Research | 2025 |
| **51%** are not taking an inventory to identify every certificate | Ponemon Institute | 2020 |
| **56.6%** concerned about ability to track certificate expiration dates | DigiCert, "Trust Pulse Survey" | 2025 |
| **72%** unaware of or don't know details of upcoming 47-day cert lifetime changes | CSC Research | 2025 |

### Certificate Volume & Sprawl

| Statistic | Source | Year |
|-----------|--------|------|
| Average organisation manages **81,000+** internally trusted certificates | Keyfactor, "2024 PKI & Digital Trust Report" | 2024 |
| Average **114,591** internal certificates per organisation | Ponemon Institute / Keyfactor | 2020 |
| **80%** expect growth in certificate volumes in next 12 months | DigiCert, "Trust Pulse Survey" | 2025 |
| Nearly **60%** of enterprises use 3+ SSL providers | CSC Research | 2025 |
| Average organisation uses **9 different** PKI/CA solutions; **37%** use more than 10 | Keyfactor, "2023 State of Machine Identity Report" | 2023 |

### Machine Identity Scale

| Statistic | Source | Year |
|-----------|--------|------|
| Machine identities outnumber human identities **82 to 1** | CyberArk, "2025 Identity Security Landscape" | 2025 |
| Machine identities outnumber humans **45 to 1** | Gartner estimate | 2024 |
| In cloud environments, machine identities outnumber humans **40,000 to 1** | Sysdig, "2025 Cloud-Native Security and Usage Report" | 2025 |
| Non-human identities grew **44%** from 2024 to 2025 | Entro Labs, "NHI & Secrets Risk Report" | 2025 |
| **79%** anticipate machine identity volumes to spike by up to **150%** | CyberArk, "2025 State of Machine Identity Security Report" | 2025 |

### Security Breaches Linked to Machine Identities

| Statistic | Source | Year |
|-----------|--------|------|
| **50%** of security leaders reported breaches linked to compromised machine identities | CyberArk, "2025 State of Machine Identity Security Report" | 2025 |
| Breaches led to: app launch delays (51%), outages impacting CX (44%), unauthorised access to sensitive data | CyberArk | 2025 |
| **42%** lack a unified approach to securing machine identities | CyberArk | 2025 |

### Staffing & Automation Gaps

| Statistic | Source | Year |
|-----------|--------|------|
| **42%** cite insufficient staffing/expertise as top obstacle to CLM | Keyfactor / Wakefield Research | 2025 |
| **70%** face pressure to automate certificate lifecycle management | Keyfactor / Wakefield Research | 2025 |
| **84%** plan to increase automation investment within 12 months | Keyfactor / Wakefield Research | 2025 |
| Only **46%** have automated certificate renewals | Keyfactor / Wakefield Research | 2025 |
| Manual renewal: ~**30 minutes**/cert. Automated: ~**15 seconds**/cert | Forrester / AppViewX TEI study | 2024 |
| Average **2.6 hours** to identify + **2.7 hours** to remediate a cert outage, requiring **8 staff** | Keyfactor, "2024 PKI & Digital Trust Report" | 2024 |

### 47-Day Certificate Lifetime Impact

| Statistic | Source | Year |
|-----------|--------|------|
| CA/Browser Forum voted to reduce TLS cert lifetimes to **47 days by 2029** (phased: 200 days in 2026, 100 days in 2027, 47 days in 2029) | CA/Browser Forum, Ballot SC-081v3 | 2025 |
| 1,000 certs = **7,766 renewal operations/year** = **21 renewals every working day** | AppViewX analysis | 2025 |
| Represents an **8x increase** in renewal workloads vs annual renewals | Multiple industry sources | 2025 |

---

## Key Reference URLs

- Keyfactor 2025 Digital Trust Digest: https://www.keyfactor.com/press-releases/keyfactor-research-reveals-digital-certificate-outages-a-weekly-reality-for-1-in-10-enterprises/
- Keyfactor 2024 PKI & Digital Trust Report: https://www.keyfactor.com/2024-pki-and-digital-trust-report/
- Keyfactor 2023 State of Machine Identity Report: https://www.keyfactor.com/state-of-machine-identity-management-2023/
- CyberArk 2025 State of Machine Identity Security Report: https://www.cyberark.com/state-of-machine-identity-security-report/
- DigiCert Trust Pulse Survey: https://www.digicert.com/news/digicert-survey-finds-manual-processes-expose-organizations
- CSC Research (40% at risk): https://www.cscglobal.com/service/press/csc-research-finds-enterprises-at-risk-ssl-expiration/
- Ponemon/Keyfactor ($11.1M cost): https://www.keyfactor.com/blog/how-one-expired-certificate-can-cause-a-11-million-outage/
- CA/Browser Forum 47-day ballot: https://www.digicert.com/blog/tls-certificate-lifetimes-will-officially-reduce-to-47-days
- CyberArk (82:1 ratio): https://www.cyberark.com/press/machine-identities-outnumber-humans-by-more-than-80-to-1-new-report-exposes-the-exponential-threats-of-fragmented-identity-security/
- Sysdig (40,000:1 in cloud): https://www.sysdig.com/press-releases/2025-usage-report
- Forrester TEI / DigiCert ONE (312% ROI): https://www.globenewswire.com/news-release/2025/07/29/3123309/0/en/Total-Economic-Impact-Study-Shows-312-ROI-with-DigiCert-ONE.html
- Forrester TEI / AppViewX (302% ROI): https://www.appviewx.com/blogs/forrester-tei-study-cost-certificate-lifecycle-management/

---

## Top Headline Stats for Slides

These are the strongest replacements/complements for the existing "40% at risk" stat:

1. **86%** experienced at least one outage from mismanaged certs (Keyfactor 2025)
2. **81%** experienced 2+ disruptive outages in two years (Keyfactor/Ponemon 2022)
3. **62%** don't know how many certificates they have (Ponemon 2020)
4. **$11.1M** average cost per certificate incident (Ponemon)
5. Machine identities outnumber humans **82:1** (CyberArk 2025)
6. **47-day** cert lifetimes coming by 2029 = **8x** increase in renewal workload
7. Only **17%** have complete real-time certificate visibility (Keyfactor 2025)

---

> **Note**: Some Australian incidents (CBA, NAB, Telstra) involve general IT outages where certificate/auth infrastructure was a contributing factor rather than the sole root cause. Verify specific details before citing in customer-facing materials. The Ericsson/O2/SoftBank and Equifax incidents are the most thoroughly documented certificate-specific outages.
