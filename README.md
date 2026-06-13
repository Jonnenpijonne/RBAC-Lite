# RBAC-Lite

**Lightweight WordPress access-control plugin and governance example for partner-based multi-tenant environments.**

RBAC-Lite demonstrates practical RBAC/IAM concepts in a WordPress context: users can be assigned to partner organizations, non-admin users are restricted to their own partner context, and access-management events can be recorded for auditability.

The repository also demonstrates how access-control-related changes can be governed through Gatehouse-style quality gates: risk classification, approvals, rollback planning, validation and audit evidence.

> **Concept note:** RBAC-Lite is an intentionally lightweight reference implementation seed and governance example, not the final enterprise implementation. For the intended use as a concept scaffold / AI-assisted handoff artifact, see [docs/CONCEPT_NOTE.md](docs/CONCEPT_NOTE.md).

---

## What this repository demonstrates

| Area | Evidence |
| --- | --- |
| RBAC / IAM thinking | Partner-based access context and user assignment |
| Tenant / partner isolation | Non-admin users are scoped to their own partner context |
| Auditability | Audit logging model for login and partner-change events |
| WordPress operations | Single-plugin architecture using WordPress hooks and user meta |
| Change governance | Gatehouse compliance example and CI validation workflow |
| DevSecOps documentation | Risk class, approvals, rollback and evidence reporting |

---

## Current repository structure

```text
sadepois-core/
└── sadepois-core.php          # Main WordPress plugin file

.github/workflows/
└── compliance-check.yml       # Gatehouse compliance validation workflow

examples/
└── rbac-lite-partner-isolation-change.md

docs/
├── CONCEPT_NOTE.md
├── DEVELOPER_GUIDE.md
├── RBAC_LITE_GATEHOUSE_COMPLETION_REPORT.md
└── TECHNICAL_ARCHITECTURE.md

validation/
├── pre-merge-checks/          # Legacy validator
└── pre_merge_checks/          # Modular validator / CLI
```

> Note: the plugin directory is currently `sadepois-core/` and the main plugin file is `sadepois-core/sadepois-core.php`. Some internal class/function names still use the original `SadePois_Core` naming for compatibility with the earlier project history.

---

## Plugin scope

RBAC-Lite Core provides a lightweight access-control baseline for partner, reseller, franchise or subsidiary-style environments.

Core concepts:

- Partner-based user assignment through WordPress user meta
- User-list filtering for non-admin users
- Admin bypass for controlled management access
- Fail-safe empty-partner behavior
- Audit logging for access-management events
- NDA / terms enforcement concept

This is a lightweight reference implementation and portfolio example, not a finished enterprise IAM platform.

---

## Installation concept

Upload the plugin directory into WordPress:

```text
/wp-content/plugins/sadepois-core/sadepois-core.php
```

Then activate it in WordPress Admin:

```text
Plugins -> Installed Plugins -> RBAC-Lite Core -> Activate
```

After activation, verify:

- the plugin is active
- partner settings are visible for admin users
- partner assignment can be saved to a user profile
- non-admin users only see users in the same partner context
- audit log entries are created for relevant events

---

## Governance & Gatehouse integration

RBAC-Lite is the access-control use case. Gatehouse is the governance and validation layer.

The related quality-gate workflow validates RBAC-Lite change requests with:

- required change-request sections
- risk classification
- rollback planning
- test plan requirements
- approval count requirements
- CISO / freeze checks for high-risk changes
- audit report generation

Workflow file:

```text
.github/workflows/compliance-check.yml
```

Default example:

```text
examples/rbac-lite-partner-isolation-change.md
```

---

## Local validation

Run the legacy validator:

```bash
python validation/pre-merge-checks/validate-change-request.py examples/rbac-lite-partner-isolation-change.md
```

Run the modular validator:

```bash
PYTHONPATH=. python validation/pre_merge_checks/cli.py examples/rbac-lite-partner-isolation-change.md
```

Expected result:

```text
QUALITY GATE: PASSED
Errors: 0
Warnings: 0
```

---

## Key documentation

- [Concept Note](docs/CONCEPT_NOTE.md)
- [Developer Guide](docs/DEVELOPER_GUIDE.md)
- [Technical Architecture](docs/TECHNICAL_ARCHITECTURE.md)
- [RBAC-Lite + Gatehouse Completion Report](docs/RBAC_LITE_GATEHOUSE_COMPLETION_REPORT.md)

---

## Portfolio summary

RBAC-Lite demonstrates a partner-based access-control use case, while Gatehouse validates the governance side: risk class, approvals, rollback plan and audit evidence.

The goal is not only to show a plugin concept, but to make the related access-control change auditable, reviewable and CI/CD-validatable.

---

## Status

| Area | Status |
| --- | --- |
| Plugin concept | Implemented as lightweight baseline |
| Gatehouse validation example | Implemented |
| Compliance workflow | Implemented |
| Legacy validator | Present |
| Modular validator / CLI | Present |
| Enterprise IAM readiness | Not claimed |

---

## License

GPL-2.0+
