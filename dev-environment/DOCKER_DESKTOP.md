# Docker Desktop / Docker Manager Workflow

This document explains how the local RBAC-Lite Docker Compose environment appears and can be managed in Docker Desktop or another graphical Docker manager.

The purpose is operational clarity: the stack can be started from the command line, then inspected, stopped, restarted and reviewed from Docker Desktop without changing the repository structure.

## Scope

This is a local development and validation workflow.

It is not:

- a production deployment model
- a hosting setup
- a cloud deployment
- a Kubernetes setup
- a monitoring stack
- a security hardening guide

## Compose project

The documented command uses an explicit Compose project name:

```bash
docker compose -p rbac-lite-local -f dev-environment/docker-compose.yml --env-file dev-environment/.env.example up -d
```

This makes the environment easier to recognize in Docker Desktop.

Expected project / stack name:

```text
rbac-lite-local
```

Expected containers:

```text
rbac-lite-local-db
rbac-lite-local-wordpress
```

Expected local URL:

```text
http://localhost:8080
```

## Docker Desktop usage

After starting the environment from the repository root, open Docker Desktop and check the **Containers** view.

You should see a Compose application / project named approximately:

```text
rbac-lite-local
```

Inside it, the expected services are:

| Service | Container name | Purpose |
| --- | --- | --- |
| `db` | `rbac-lite-local-db` | Local MariaDB database for WordPress test data |
| `wordpress` | `rbac-lite-local-wordpress` | Local WordPress runtime with RBAC-Lite mounted as a plugin |

## What can be managed from Docker Desktop

Docker Desktop can be used to:

- view container status
- start and stop the Compose stack
- restart individual containers
- open container logs
- inspect container environment and mounts
- confirm that only local test containers are running
- remove the Compose stack after validation

## What should still be done from the command line

Use the command line for repeatable documentation and evidence:

```bash
docker compose -p rbac-lite-local -f dev-environment/docker-compose.yml --env-file dev-environment/.env.example ps

docker compose -p rbac-lite-local -f dev-environment/docker-compose.yml --env-file dev-environment/.env.example logs wordpress --tail=80

docker compose -p rbac-lite-local -f dev-environment/docker-compose.yml --env-file dev-environment/.env.example logs db --tail=80
```

The reset script should also be run from the repository root:

```bash
bash dev-environment/scripts/reset-local.sh
```

## Localhost boundary

The WordPress service is bound to localhost only:

```yaml
ports:
  - "127.0.0.1:8080:80"
```

This means the local WordPress instance is available from the local machine at:

```text
http://localhost:8080
```

It is not intentionally exposed to the local network.

## Volumes and test data

The Compose stack uses named Docker volumes for local test data:

```text
rbac_lite_db_data
wordpress_data
```

This keeps the test database and WordPress files outside the Git repository.

Important boundary:

```text
Docker volumes may contain local test data. They are not source code and should not be committed to Git.
```

The reset script is the preferred documented cleanup method because it targets the local Compose project and test database intentionally.

## Validation workflow

Recommended workflow:

1. Start the environment from the command line.
2. Confirm the Compose project appears in Docker Desktop.
3. Open `http://localhost:8080`.
4. Complete WordPress setup if needed.
5. Activate the RBAC-Lite Core plugin.
6. Perform manual validation steps from `dev-environment/README.md`.
7. Capture evidence only when needed.
8. Stop or reset the environment after validation.

## Evidence use

Docker Desktop is useful for visual confirmation, but evidence should remain text-first where possible:

- command output
- container status
- relevant logs
- documented screenshots only when they clarify the validation result

Screenshots should not include secrets, real users, customer data or private environment details.

## Summary

Docker Desktop is used here as a local operational view over the documented Docker Compose stack.

The authoritative environment definition remains:

```text
dev-environment/docker-compose.yml
dev-environment/.env.example
dev-environment/scripts/reset-local.sh
```
