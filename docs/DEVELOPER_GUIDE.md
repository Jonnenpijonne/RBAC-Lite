# RBAC-Lite Developer Guide

This document preserves the longer technical and usage-oriented Markdown material that previously lived in the root `README.md`.

The root README is now intentionally shorter and portfolio-oriented. This guide keeps the practical owner/developer instructions, examples and test notes in a dedicated document.

---

## Owner's Guide

### What is RBAC-Lite?

RBAC-Lite Core is a lightweight WordPress plugin that enables a simple multi-tenant / partner-based access-control model for organizations managing multiple partners, offices, subsidiaries, franchisees or reseller-style groups.

It demonstrates:

- partner isolation
- audit logging
- NDA / terms enforcement concept
- user-to-partner assignment
- admin bypass for controlled management access
- fail-safe empty-partner behavior

---

## Installation & Activation

Current plugin path in this repository:

```text
sadepois-core/sadepois-core.php
```

Install concept:

1. Upload the plugin directory to WordPress:

```text
/wp-content/plugins/sadepois-core/sadepois-core.php
```

2. Activate in WordPress Admin:

```text
Plugins -> Installed Plugins -> RBAC-Lite Core -> Activate
```

3. Verify installation:

- plugin appears as `RBAC-Lite Core`
- partner settings appear for admin users
- partner assignment can be saved
- non-admin user visibility is scoped by partner context
- audit log entries are created for relevant events

---

## Quick Start: Assigning Partners to Users

### Step 1: Create or edit a user

1. Go to WordPress Admin -> Users.
2. Click Edit on a user or create a new user.

### Step 2: Assign Partner ID

1. Scroll to the Partner Settings section.
2. Enter a Partner ID, for example:

```text
PARTNER_A
ACME_CORP
SUBSIDIARY_1
RESELLER_EU
```

3. Click Update Profile.

### Step 3: Verify isolation

1. Log in as a non-admin user.
2. Go to the Users list.
3. Verify that the user only sees users in the same partner context.

---

## Audit Log Monitoring

View recent user activity from the database:

```sql
SELECT * FROM wp_rbac-lite_audit_log
ORDER BY created_at DESC;
```

Example audit log entries:

```text
| id | user_id | event_type     | meta                                      | created_at          |
| -- | ------- | -------------- | ----------------------------------------- | ------------------- |
| 1  | 2       | login          | {"username":"partner_a_user"}          | 2026-04-29 10:30:00 |
| 2  | 2       | partner_update | {"old_partner_id":null,"new_partner_id":"PARTNER_A"} | 2026-04-29 10:31:00 |
| 3  | 3       | login          | {"username":"partner_b_user"}          | 2026-04-29 10:32:00 |
```

---

## Common Use Cases

### 1. Multi-office setup

```text
Partner ID: OFFICE_NYC    -> users in New York office
Partner ID: OFFICE_LA     -> users in Los Angeles office
Partner ID: OFFICE_LONDON -> users in London office
```

Each office only sees users in its own partner context.

### 2. Franchisor and franchisees

```text
Partner ID: FRANCHISOR    -> corporate admins / management users
Partner ID: FRANCHISEE_01 -> franchise owner and staff
Partner ID: FRANCHISEE_02 -> another franchise
```

### 3. Reseller network

```text
Partner ID: RESELLER_US_WEST
Partner ID: RESELLER_US_EAST
Partner ID: RESELLER_EU
```

---

## Troubleshooting

### Partner Settings field not appearing

Likely cause: user is not logged in as an admin.

Fix: log in with an admin account and verify capability checks.

### Users seeing all users

Likely cause: the current account is an admin account and admin bypass is intentional.

Fix: test with a non-admin account.

### User has no partner ID assigned

Likely cause: partner field was left blank.

Fix: assign a Partner ID in the user profile.

### Audit logs not appearing

Likely causes:

- audit table was not created
- plugin activation hook did not run
- event hook was not triggered

Fix:

- reactivate plugin to trigger table creation
- verify database table exists
- verify login / partner update event path

---

## Support & Debugging

Check plugin status with WP-CLI:

```bash
wp plugin status rbac-lite-core
```

Because the current repository folder is `sadepois-core`, local plugin slug behavior may depend on the deployed folder name. If deployed as `sadepois-core`, check:

```bash
wp plugin status sadepois-core
```

Check from PHP:

```php
if ( class_exists( 'SadePois_Core' ) ) {
    echo 'RBAC-Lite Core is active';
}
```

View audit logs via WP-CLI:

```bash
wp db query "SELECT * FROM wp_rbac-lite_audit_log LIMIT 10;"
```

---

# Developer Manual

## Architecture Overview

Current repository structure:

```text
sadepois-core/
└── sadepois-core.php          # Main plugin file

README.md                     # Portfolio-oriented overview
docs/DEVELOPER_GUIDE.md       # This guide
docs/TECHNICAL_ARCHITECTURE.md
```

The plugin uses a single-file WordPress architecture. The main class is still named:

```php
SadePois_Core
```

This naming is retained from the earlier project history. The repository and plugin framing are now RBAC-Lite.

---

## Core Class

### `SadePois_Core`

Singleton pattern. Initialize once:

```php
$rbac_lite = SadePois_Core::get_instance();
```

The singleton pattern is used to avoid duplicate hook registration and keep the plugin lifecycle simple.

---

## Key Methods and Helper Functions

### Get user's Partner ID

```php
$partner_id = sp_get_user_partner_id( $user_id );
// Returns: string or null
```

Example:

```php
$partner = sp_get_user_partner_id( 42 );

if ( $partner ) {
    echo 'User is part of: ' . $partner;
} else {
    echo 'User has no partner assigned';
}
```

---

### Check if users are in the same partner context

```php
$is_same = sp_is_same_partner( $user_id_1, $user_id_2 );
// Returns: bool
```

Example:

```php
if ( sp_is_same_partner( 42, 43 ) ) {
    echo 'Both users belong to the same partner';
} else {
    echo 'Users are in different partners';
}
```

---

### Assign partner to user

```php
sp_set_user_partner_id( $user_id, $partner_id );
// Returns: bool
// Expected side effect: audit log entry
```

Example:

```php
if ( sp_set_user_partner_id( 42, 'PARTNER_A' ) ) {
    echo 'Partner assigned';
} else {
    echo 'Failed to assign partner';
}
```

---

## Hooks & Filters

### `pre_get_users`

Used to filter user lists for non-admin users.

Conceptual behavior:

```php
// Non-admin sees only users with the same sp_partner_id.
get_users( array(
    'include' => array( /* users with same partner ID */ ),
) );

// Admin sees all users.
```

Extension example:

```php
add_filter( 'pre_get_users', function( $args ) {
    // Custom partner filtering logic.
    return $args;
}, 11 );
```

---

### `wp_login`

Used to log successful login events.

Conceptual audit entry:

```text
event_type: login
meta: { "username": "user_login" }
```

---

## Database Schema

### Audit table

Current concept:

```sql
CREATE TABLE wp_rbac-lite_audit_log (
    id mediumint(9) NOT NULL AUTO_INCREMENT,
    user_id bigint(20) NOT NULL,
    event_type varchar(50) NOT NULL,
    meta longtext DEFAULT NULL,
    created_at datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY user_id (user_id),
    KEY event_type (event_type)
);
```

Columns:

| Column | Purpose |
| --- | --- |
| `id` | Unique audit entry ID |
| `user_id` | WordPress user ID |
| `event_type` | Type of action, such as login or partner update |
| `meta` | JSON metadata stored as string |
| `created_at` | Timestamp |

---

## User Meta Fields

### `sp_partner_id`

| Field | Value |
| --- | --- |
| Key | `sp_partner_id` |
| Type | String |
| Purpose | Partner assignment for user visibility and isolation |

Retrieve:

```php
$partner = get_user_meta( $user_id, 'sp_partner_id', true );
```

Set:

```php
update_user_meta( $user_id, 'sp_partner_id', 'PARTNER_A' );
```

---

## Code Examples

### Example 1: Bulk assign partners

```php
$user_ids = array( 2, 3, 4, 5, 6 );

foreach ( $user_ids as $user_id ) {
    sp_set_user_partner_id( $user_id, 'PARTNER_A' );
}
```

---

### Example 2: Get all users in a partner

```php
function get_partner_users( $partner_id ) {
    return get_users( array(
        'meta_key'   => 'sp_partner_id',
        'meta_value' => $partner_id,
        'fields'     => 'ID',
    ) );
}

$partner_a_users = get_partner_users( 'PARTNER_A' );
```

---

### Example 3: Get posts for a partner

```php
function get_posts_for_partner( $partner_id ) {
    $users = get_partner_users( $partner_id );

    return get_posts( array(
        'author__in'     => $users,
        'posts_per_page' => -1,
    ) );
}

$posts = get_posts_for_partner( 'PARTNER_A' );
```

---

### Example 4: Audit log query

```php
global $wpdb;

$table = $wpdb->prefix . 'rbac-lite_audit_log';

$logs = $wpdb->get_results( $wpdb->prepare(
    "SELECT * FROM $table WHERE event_type = %s ORDER BY created_at DESC LIMIT %d",
    'login',
    50
) );

foreach ( $logs as $log ) {
    echo $log->user_id . ' logged in at ' . $log->created_at . "\n";
}
```

---

## Safety & Security

### Input sanitization

Partner IDs should be sanitized before storage:

```php
$partner_id = sanitize_text_field( $partner_id );
```

### Output escaping

Displayed values should be escaped:

```php
echo esc_attr( $partner_id );
echo esc_html( $partner_id );
```

### Admin capability check

Partner fields should only be editable by privileged users:

```php
if ( ! current_user_can( 'manage_options' ) ) {
    return;
}
```

### Fail-safe empty partner handling

If a non-admin user has no partner ID, they should see no other users:

```php
$args['include'] = ! empty( $same_partner_users ) ? $same_partner_users : array( -1 );
```

---

## Testing

### Test 1: Partner isolation

```php
$user_a = wp_create_user( 'user_a', 'pass', 'a@test.com' );
$user_b = wp_create_user( 'user_b', 'pass', 'b@test.com' );

sp_set_user_partner_id( $user_a, 'PARTNER_A' );
sp_set_user_partner_id( $user_b, 'PARTNER_B' );

assert( sp_is_same_partner( $user_a, $user_b ) === false );
```

### Test 2: Audit logging

```php
global $wpdb;

$table = $wpdb->prefix . 'rbac-lite_audit_log';

sp_set_user_partner_id( 2, 'PARTNER_A' );

$logs = $wpdb->get_results( "SELECT * FROM $table WHERE event_type = 'partner_update'" );

assert( count( $logs ) > 0 );
```

### Test 3: Admin bypass

```php
wp_set_current_user( 1 );

$users = get_users();

echo 'Admin sees all users';
```

---

## Gatehouse Validation Commands

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

## Performance Considerations

- User meta queries should stay simple and indexed through normal WordPress metadata patterns.
- Audit log queries should be filtered by event type, user ID and recent timestamp where possible.
- Keep the plugin lightweight until there is a real reason to introduce a larger architecture.

---

## Roadmap Ideas

- REST API endpoints for partner management
- Advanced permission matrix
- Partner-level reporting dashboards
- WooCommerce order visibility integration
- Bulk partner assignment UI
- Separate admin screen for audit log viewing

---

## Relationship to Gatehouse

RBAC-Lite is the access-control use case.

Gatehouse is the change governance and validation layer.

Together they demonstrate how access-control-related changes can be documented, risk-classified, approved, validated and evidenced.
