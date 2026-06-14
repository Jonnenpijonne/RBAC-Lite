# RBAC-Lite Safety Fix Report

## Scope

This report documents a focused RBAC-Lite safety fix.

No README changes were made.

## Repository

```text
Jonnenpijonne/RBAC-Lite
```

## Fixed file

```text
sadepois-core/sadepois-core.php
```

## Issues fixed

### 1. Invalid PHP helper variable name

The global helper functions used an invalid PHP variable name:

```php
$rbac-lite
```

PHP variables cannot contain a hyphen. The helper variable was changed to:

```php
$rbac_lite
```

Affected helper functions:

```text
sp_get_user_partner_id
sp_is_same_partner
sp_set_user_partner_id
```

### 2. Missing partner context changed to fail-closed behavior

Before the fix, a non-admin user without `sp_partner_id` returned the original user query arguments.

That behavior could leave the user list unfiltered.

The behavior was changed so that a non-admin user without partner context receives an empty include list:

```php
$args['include'] = array( -1 );
```

This aligns the behavior with the intended partner-isolation model.

### 3. Partner ID save protected with nonce verification

The user profile partner ID save path now checks a WordPress nonce before accepting `sp_partner_id` input.

Added profile-field nonce:

```php
wp_nonce_field( 'sp_save_partner_id', 'sp_partner_id_nonce' );
```

Added save-side verification:

```php
$nonce = sanitize_text_field( wp_unslash( $_POST['sp_partner_id_nonce'] ) );
if ( ! wp_verify_nonce( $nonce, 'sp_save_partner_id' ) ) {
    return;
}
```

The submitted partner ID is also unslashed and sanitized before saving.

## What was not changed

This was intentionally a narrow safety correction.

Not changed:

- README
- repository positioning
- documentation structure
- Gatehouse integration model
- plugin naming / directory naming
- license
- workflow files
- broader architecture

## Result

The RBAC-Lite concept remains the same:

```text
partner-based access-control seed + audit logging + Gatehouse-style governance example
```

The fix improves the technical safety of the implementation by removing an invalid PHP variable name, aligning missing partner context with fail-closed behavior and adding nonce protection to partner assignment updates.

## Portfolio framing

This correction is useful portfolio evidence because it shows that the project was not only documented, but also reviewed and tightened against concrete implementation-level issues.

The appropriate framing remains conservative:

```text
RBAC-Lite is a lightweight access-control governance reference seed, not a final enterprise IAM platform.
```
