# ERA Wallet controlled production rollout plan

Recommended ETKN limits below are operational caps for the rollout cohort, not guarantees or protocol-enforced limits. A rollout owner must approve funding and may lower or pause limits at any time.

## Stage 1: Internal signed build validation

- **Entry:** analyzer/tests/builds/checksums pass; internal signing available; security review complete.
- **Participants:** up to 5 named internal testers.
- **Maximum recommended exposure:** 0.1 ETKN per AI position and 1 ETKN total per tester.
- **Monitoring:** direct tester channel, transaction/finality review, runtime compatibility dashboard, artifact checksum log.
- **Support:** same-business-day engineering ownership.
- **Stop:** secret exposure, checksum/signature mismatch, duplicate/unknown submission, balance/position mismatch, runtime drift, endpoint outage, or critical crash.
- **Exit:** physical-device core flows pass on at least two Android devices and two Windows systems; all incidents resolved.

## Stage 2: Invite-only production beta

- **Entry:** Stage 1 exit met; signed artifacts; approved invite, risk, privacy, and support material.
- **Participants:** up to 25 identified participants.
- **Maximum recommended exposure:** 1 ETKN per AI position and 10 ETKN total per participant.
- **Monitoring:** daily runtime/finality/endpoint review and incident queue; weekly cohort report.
- **Support:** published support page/email with 1-business-day acknowledgement.
- **Stop:** any critical security issue, repeated unresolved transaction ambiguity, material payout mismatch, high-severity phishing, or legal/compliance hold.
- **Exit:** two stable weeks, no unresolved severity-1/2 incident, reconciliation evidence accepted, support load sustainable.

## Stage 3: Limited external participant beta

- **Entry:** Stage 2 exit met; legal/compliance approval for selected jurisdictions; signed and independently checksum-verified artifacts.
- **Participants:** up to 100 approved participants.
- **Maximum recommended exposure:** 5 ETKN per AI position and 25 ETKN total per participant.
- **Monitoring:** daily operational dashboard, weekly security/dependency review, fraud/phishing monitoring, support metrics.
- **Support:** documented triage/escalation and incident communications.
- **Stop:** security compromise, malicious copy campaign, runtime incompatibility, material financial mismatch, regulatory concern, or support capacity breach.
- **Exit:** four stable weeks, physical-device matrix complete, no unresolved high-severity issue, public documentation approved.

## Stage 4: Public downloadable release

- **Entry:** physical-device QA, Android/Windows signing, legal and compliance gates PASS; public artifact host and checksums independently verified.
- **Participants:** public, initially rate-limited operationally where feasible.
- **Maximum recommended exposure:** 10 ETKN per AI position during the initial public period; users remain responsible for risk.
- **Monitoring:** continuous endpoint/runtime alerting, daily artifact/phishing review, incident metrics and public status notices.
- **Support:** published support SLA, known-issues page, incident banner capability.
- **Stop:** compromised artifact/signing key, critical vulnerability, runtime drift, chain halt, widespread reconciliation failure, or compliance directive.
- **Exit:** stable public period and store-qualification evidence package complete.

## Stage 5: Application-store qualification

- **Entry:** Stage 4 stable; store privacy/data-safety, signing, export-compliance, screenshots, and review notes approved.
- **Participants:** store availability by approved country/region.
- **Maximum recommended exposure:** retain 10 ETKN initial guidance until a reviewed risk decision changes it.
- **Monitoring:** store crash/quality signals only if privacy-approved tooling is later added; otherwise operational/support signals and chain telemetry.
- **Support:** store listing plus official support page/email.
- **Stop:** store rejection, policy breach, security incident, runtime incompatibility, or regulatory restriction.
- **Exit:** approved listings, staged rollout health, support and update process demonstrated.

Invite-only testing is controlled production testing, not unrestricted public production.

