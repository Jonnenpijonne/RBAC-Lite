\# Local Docker Validation Report — RBAC-Lite



Date: 2026-06-19

Repository: `Jonnenpijonne/RBAC-Lite`

Scope: Local Docker Compose test environment

Related PR: `#4 fix: improve local Docker environment validation`



\## Purpose



This report records the local validation evidence for the RBAC-Lite Docker Compose test environment after improving the MariaDB healthcheck.



The goal was to verify that the local WordPress + MariaDB environment starts reliably, remains bound to localhost, and supports safe local validation of the RBAC-Lite plugin without production data.



\## Environment



\* Host: Windows / Git Bash / Docker Desktop

\* Compose project: `rbac-lite-local`

\* WordPress service: `rbac-lite-local-wordpress`

\* Database service: `rbac-lite-local-db`

\* Database image: `mariadb:11`

\* WordPress image: `wordpress:latest`

\* Local URL: `http://127.0.0.1:8080`



\## Issue Observed



The MariaDB container started successfully and logs showed that the database was ready for connections, but Docker Compose continued to report the database container as `health: starting`.



Because the WordPress service depended on the database health state, WordPress did not start reliably until the database healthcheck was corrected.



\## Root Cause



The original healthcheck used an unauthenticated `mysqladmin ping` command:



```yaml

test: \["CMD", "mysqladmin", "ping", "-h", "localhost"]

```



This did not reliably verify database readiness in the MariaDB 11 container context.



\## Change Made



The database healthcheck was replaced with a credential-based `mariadb-admin` check:



```yaml

healthcheck:

&#x20; test: \["CMD-SHELL", "mariadb-admin ping -h 127.0.0.1 -u$${MYSQL\_USER} -p$${MYSQL\_PASSWORD} --silent"]

&#x20; interval: 10s

&#x20; timeout: 5s

&#x20; retries: 10

&#x20; start\_period: 30s

```



The obsolete top-level Docker Compose `version` field was also removed.



\## Validation Commands



Docker Compose configuration validation:



```bash

docker compose -p rbac-lite-local \\

&#x20; -f dev-environment/docker-compose.yml \\

&#x20; --env-file dev-environment/.env.example \\

&#x20; config

```



Start/update local environment:



```bash

docker compose -p rbac-lite-local \\

&#x20; -f dev-environment/docker-compose.yml \\

&#x20; --env-file dev-environment/.env.example \\

&#x20; up -d

```



Check container status:



```bash

docker compose -p rbac-lite-local \\

&#x20; -f dev-environment/docker-compose.yml \\

&#x20; --env-file dev-environment/.env.example \\

&#x20; ps

```



\## Validation Result



The validation succeeded.



Observed result:



\* MariaDB container reached `healthy`

\* WordPress container reached `healthy`

\* WordPress remained bound to localhost only

\* Docker Compose configuration validation passed

\* obsolete Compose `version` warning was removed

\* no production data or real credentials were used



\## Scope Control



This change was intentionally limited to the local Docker test environment.



No changes were made to:



\* RBAC-Lite plugin logic

\* production deployment configuration

\* GitHub Actions workflows

\* root repository README

\* real credentials

\* customer data

\* monitoring stack

\* cloud deployment

\* Kubernetes or orchestration layers



\## Evidence Summary



The fix improves local validation reliability by ensuring that WordPress waits for a database container that is actually ready to accept authenticated MariaDB connections.



This supports the RBAC-Lite portfolio goal of a safe, repeatable and disposable local test environment for access-control governance validation.



