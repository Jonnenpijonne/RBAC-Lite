#!/bin/bash
set -euo pipefail

# Reset script for RBAC-Lite local Docker Compose environment
# This script removes only the local database volume for this Compose project
# and optionally restarts the environment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_NAME="rbac-lite-local"
VOLUME_NAME="${PROJECT_NAME}_rbac_lite_db_data"

echo "=================================================="
echo "  RBAC-Lite Local Environment Reset"
echo "=================================================="
echo ""
echo "This script will:"
echo "  1. Stop the Docker Compose stack"
echo "  2. Remove the local database volume: $VOLUME_NAME"
echo "  3. Optionally restart the environment"
echo ""
echo "WARNING: Local test data will be deleted."
echo "This affects only this Compose project ($PROJECT_NAME)."
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo "=================================================="
echo "  Stopping Compose stack..."
echo "=================================================="

docker compose -p "$PROJECT_NAME" -f "$SCRIPT_DIR/docker-compose.yml" --env-file "$SCRIPT_DIR/.env.example" down || true

echo ""
echo "=================================================="
echo "  Removing database volume..."
echo "=================================================="

docker volume rm "$VOLUME_NAME" 2>/dev/null || echo "Volume not found or already removed."

echo ""
echo "=================================================="
echo "  Reset complete"
echo "=================================================="
echo ""

read -p "Restart the environment? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting Compose stack..."
    docker compose -p "$PROJECT_NAME" -f "$SCRIPT_DIR/docker-compose.yml" --env-file "$SCRIPT_DIR/.env.example" up -d
    echo ""
    echo "Compose stack started. Check status with:"
    echo "  docker compose -p $PROJECT_NAME -f $SCRIPT_DIR/docker-compose.yml --env-file $SCRIPT_DIR/.env.example ps"
else
    echo "Skipped restart."
fi
