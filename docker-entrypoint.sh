#!/bin/bash
set -e

# Install composer packages
./craft update/composer-install

# Run pending migrations
./craft migrate/all --no-backup

# Apply changes from project config (unless ENVIRONMENT=dev)
# --force will apply everything from the project config files
[ "$ENVIRONMENT" != "dev" ] && ./craft project-config/apply --force 

# https://docs.docker.com/engine/reference/builder/#exec-form-entrypoint-example
exec "$@"