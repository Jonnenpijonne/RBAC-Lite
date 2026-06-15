# RBAC-Lite WordPress Hook Hardening Report

## Scope

This report records a focused WordPress technical hardening pass for RBAC-Lite.

Repository:

```text
Jonnenpijonne/RBAC-Lite
```

Fixed source file:

```text
sadepois-core/sadepois-core.php
```

## Reason for the change

A follow-up review found that the previous user-list scoping implementation treated the `pre_get_users` callback parameter as an array-like argument structure.

For WordPress user queries, `pre_get_users` is better handled as a query object mutation point.

The review also identified that the audit table name used a hyphen. For WordPress and SQL compatibility, an underscore-based table suffix is safer and cleaner for a portfolio plugin baseline.

## Changes made

### 1. User query hook changed to action-style usage

Previous semantic model:

```text
pre_get_users used through add_filter
callback returned modified args-style data
```

Updated semantic model:

```text
pre_get_users used through add_action
callback mutates the WP_User_Query object
```

### 2. User-list filtering now uses query object mutation

The partner isolation logic now applies user-list scoping through the query object instead of returning an args array.

Fail-closed behavior is preserved:

```text
non-admin user without partner context -> include no users
non-admin user with partner context -> include users from the same partner
admin user -> no user-list restriction from RBAC-Lite
```

### 3. Audit table name normalized

Previous audit table suffix:

```text
rbac-lite_audit_log
```

Updated audit table suffix:

```text
rbac_lite_audit_log
```

This avoids the avoidable SQL naming risk created by a hyphen in the table suffix.

## What was not changed

This was intentionally a narrow hardening pass.

Not changed:

```text
README.md
license
project positioning
Gatehouse integration model
partner meta key
profile UI behavior
nonce behavior from the previous safety fix
broader plugin architecture
other repositories
```

## Technical interpretation

This is a WordPress technical hardening pass, not a new product feature.

It improves the implementation credibility of the RBAC-Lite baseline by aligning the user-query scoping behavior more closely with WordPress query-hook expectations and by cleaning up the audit table naming convention.

## Validation to run locally

Recommended local validation command:

```bash
php -l sadepois-core/sadepois-core.php
```

Expected result:

```text
No syntax errors detected in sadepois-core/sadepois-core.php
```

## Portfolio framing

Conservative framing:

```text
RBAC-Lite is a lightweight WordPress access-control governance reference seed.
```

Updated interview framing:

```text
RBAC-Lite demonstrates partner-based user scoping, audit logging, fail-closed behavior for missing partner context, nonce-protected profile updates and WordPress-aware query hook hardening. I position it as a portfolio baseline, not an enterprise IAM product.
```
