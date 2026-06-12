# RBAC-Lite Core: Technical Architecture

**Document Version:** 1.2.0  
**Last Updated:** 2026-06-12  
**Status:** PHASE 1 Implementation  
**Architecture Pattern:** Single-file WordPress plugin with singleton pattern

---

## 1. System Overview

RBAC-Lite Core is a lightweight WordPress plugin that demonstrates partner-based access control, user-to-partner assignment, audit logging and governance-aware change validation.

Current plugin path:

```text
sadepois-core/sadepois-core.php
```

The plugin file still uses the historical class name `SadePois_Core`. This is intentional compatibility/history naming and does not change the public RBAC-Lite repository framing.

---

## 2. High-Level Architecture

```text
WordPress installation
│
├── RBAC-Lite Core plugin
│   ├── User profile partner assignment
│   ├── Partner isolation logic
│   ├── User list filtering
│   ├── Admin bypass
│   ├── Audit logging
│   └── NDA / terms enforcement concept
│
├── WordPress user data
│   ├── wp_users
│   └── wp_usermeta: sp_partner_id
│
└── Audit table
    └── wp_rbac-lite_audit_log
```

---

## 3. Repository Layout

```text
sadepois-core/
└── sadepois-core.php          # Main WordPress plugin file

.github/workflows/
└── compliance-check.yml       # Gatehouse compliance validation workflow

examples/
└── rbac-lite-partner-isolation-change.md

docs/
├── RBAC_LITE_GATEHOUSE_COMPLETION_REPORT.md
└── TECHNICAL_ARCHITECTURE.md

validation/
├── pre-merge-checks/          # Legacy validator
└── pre_merge_checks/          # Modular validator / CLI
```

---

## 4. Architecture Principles

### 4.1 Single-file plugin baseline

RBAC-Lite is intentionally lightweight. The current plugin logic is kept in a single PHP file to keep deployment simple and reviewable.

Benefits:

- no external PHP dependencies
- simple WordPress plugin activation model
- clear audit/review surface
- easy deployment into a WordPress plugin directory

### 4.2 Hook-based WordPress integration

The plugin integrates through WordPress hooks instead of modifying WordPress core.

Core hook categories:

- plugin activation
- admin initialization
- user profile fields
- user profile save handling
- user list filtering
- login audit logging

### 4.3 Metadata-based partner assignment

Partner assignment uses WordPress user meta:

```text
meta_key:   sp_partner_id
meta_value: PARTNER_A / PARTNER_B / etc.
```

This keeps the partner assignment lightweight and compatible with normal WordPress user records.

### 4.4 Fail-safe empty partner behavior

Users without a partner context should not see unrelated partner users. Empty or missing partner assignments should fail closed rather than exposing broad visibility.

### 4.5 Admin bypass

Admin users retain management visibility. This is intentional and should be treated as a privileged access path.

---

## 5. Core Components

| Component | Purpose |
| --- | --- |
| `SadePois_Core` | Main plugin class / singleton |
| Partner user meta | Stores partner assignment per user |
| User profile field | Lets admins assign partner IDs |
| User filtering | Limits non-admin user visibility by partner context |
| Audit logging | Records access-management events |
| NDA / terms concept | Provides a governance hook for controlled access |

---

## 6. Governance Model

RBAC-Lite should be treated as an access-control-related component. Even small changes may affect visibility, permissions or auditability.

Recommended risk interpretation:

| Risk class | Example |
| --- | --- |
| Class 1 | Documentation-only change with no control impact |
| Class 2 | Governance example, validation rule or non-production access-control documentation change |
| Class 3 | Production tenant-isolation, partner-isolation, permission or audit-logging logic change |

Class 2 and Class 3 changes should include:

- impact analysis
- rollback plan
- test plan
- approval evidence
- validation output

---

## 7. Gatehouse Validation

The repository includes a Gatehouse-style compliance workflow:

```text
.github/workflows/compliance-check.yml
```

The workflow validates change-request files under:

```text
examples/*.md
templates/*.md
```

Default example:

```text
examples/rbac-lite-partner-isolation-change.md
```

The validator checks:

- required sections
- required fields
- risk class
- rollback plan
- test plan
- approval count
- CISO / freeze requirements for high-risk changes
- absolute path warnings
- audit report output

---

## 8. Local Validation Commands

Legacy validator:

```bash
python validation/pre-merge-checks/validate-change-request.py examples/rbac-lite-partner-isolation-change.md
```

Modular validator:

```bash
PYTHONPATH=. python validation/pre_merge_checks/cli.py examples/rbac-lite-partner-isolation-change.md
```

Python syntax check:

```bash
python -m py_compile validation/pre-merge-checks/validate-change-request.py
python -m py_compile validation/pre_merge_checks/*.py
```

Expected result:

```text
QUALITY GATE: PASSED
Errors: 0
Warnings: 0
```

---

## 9. Security Considerations

Key security expectations:

- sanitize partner ID input
- escape partner ID output
- restrict partner editing to admin users
- fail closed for missing partner context
- keep audit logging enabled for relevant events
- treat admin bypass as privileged access
- validate risky access-control changes before merge

---

## 10. Portfolio Interpretation

RBAC-Lite is not presented as an enterprise IAM product. It is a lightweight access-control implementation and governance portfolio example.

The core value is the combination:

```text
RBAC-Lite = access-control use case
Gatehouse = governance and validation layer
```

Together they demonstrate how access-control-related changes can be made traceable, reviewable and auditable.
