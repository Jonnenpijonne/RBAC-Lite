# Local Docker Test Environment for RBAC-Lite

## What this is

A local Docker Compose environment that runs WordPress and MariaDB, with the RBAC-Lite plugin mounted from the repository for testing and demonstration.

The environment is designed for safe local development and manual testing of the partner-isolation and access-control concepts implemented in the RBAC-Lite plugin.

## What this is not

- Not a production deployment
- Not intended for performance testing
- Not hardened for external access
- Not configured with real credentials or customer data
- Not suitable for handling sensitive information

## Prerequisites

- Docker Desktop or Docker Engine + Docker Compose
- Git (to have cloned the RBAC-Lite repository)

Verify:

```bash
docker compose version
```

## Start the environment

From the repository root:

```bash
docker compose -p rbac-lite-local -f dev-environment/docker-compose.yml --env-file dev-environment/.env.example up -d
```

Wait for services to become healthy (10-30 seconds):

```bash
docker compose -p rbac-lite-local -f dev-environment/docker-compose.yml --env-file dev-environment/.env.example ps
```

Look for:

```text
STATUS
healthy
```

## Activate the plugin in WordPress Admin

1. Open browser to: `http://localhost:8080`

2. Complete WordPress setup if prompted (create admin user and site title)

3. Go to: `Plugins` → `Installed Plugins`

4. Find: **RBAC-Lite Core**

5. Click: **Activate**

6. Confirm activation by checking the plugin appears in the active plugins list

## Manual validation steps

### Step 1: Verify plugin is active

- Admin dashboard shows: `Plugins` → `RBAC-Lite Core` is listed and active

### Step 2: Create test users

- Go to: `Users` → `Add New`
- Create User A (non-admin role): username `user_a`, assign to Partner A
- Create User B (non-admin role): username `user_b`, assign to Partner B
- Create Admin user if not already present

### Step 3: Assign partner IDs

- Go to: `Users` → `All Users`
- Edit User A:
  - Scroll to: `Partner Settings` → `Partner ID`
  - Enter: `partner_a`
  - Save
- Edit User B:
  - Scroll to: `Partner Settings` → `Partner ID`
  - Enter: `partner_b`
  - Save

### Step 4: Verify partner isolation

**Note:** Basic WordPress non-admin roles may have limited access to the Users admin screen. For this test, use an Editor or other role that can view user listings, or validate the filtering through a database query or helper function call.

- Log in as User A (non-admin, with access to user listings)
- Go to: `Users`
- Verify: User A sees only users in `partner_a` context (should see User A but not User B)
- Log out, then log in as User B
- Go to: `Users`
- Verify: User B sees only users in `partner_b` context (should see User B but not User A)
- Log out, then log in as Admin
- Go to: `Users`
- Verify: Admin sees all users (User A, User B, Admin)

Alternatively, query the filtered user list directly via WordPress CLI or database if the admin screen is not accessible.

### Step 5: Check audit log (if accessible)

- Audit events are logged to database table: `wp_rbac_lite_audit_log`
- Events include: `login`, `partner_update`
- Query via CLI or MySQL client if needed (example below)

Query audit log from command line:

```bash
docker compose -p rbac-lite-local -f dev-environment/docker-compose.yml --env-file dev-environment/.env.example exec db mysql -u wordpress_user -plocal_dev_password_change_me wordpress_rbac_lite -e "SELECT * FROM wp_rbac_lite_audit_log;"
```

## Reset / rebuild

To completely rebuild the environment and remove test data:

```bash
bash dev-environment/scripts/reset-local.sh
```

The script will:

1. Stop the Docker Compose stack
2. Remove the local database volume (test data is lost)
3. Ask if you want to restart the environment

**Warning:** This removes only the local test database. It does not affect the repository or other Docker containers.

## Why localhost binding matters

The WordPress service binds to `127.0.0.1:8080` instead of `0.0.0.0:8080`.

This means:

- WordPress is accessible from the local machine only (`http://localhost:8080`)
- WordPress is not reachable from other machines on the network
- Accidental exposure is minimized for local-only development

## Data safety

- No production data is included
- No customer data is present
- No real credentials are used (all values are local-only placeholders)
- Database values like `MYSQL_PASSWORD=local_dev_password_change_me` are intentional test values, not secrets
- Database data is stored in a local Docker named volume: `rbac_lite_db_data`
- Data persists across container restarts but is removed by the reset script
- The reset script targets only this Compose project's database volume

## What this proves

This local environment demonstrates that the RBAC-Lite plugin concept can be tested in a reproducible local WordPress runtime without production data.

The plugin source is mounted from the repository (bind mount), the database is isolated to a local Docker volume, and the WordPress service is bound to localhost only.

Manual validation of partner isolation and access-control filtering can be performed by:

1. Creating test users
2. Assigning different partner IDs
3. Logging in as different users
4. Observing that non-admin user visibility is correctly scoped to their own partner context
