#!/bin/bash
set -e

# Install composer packages
./craft update/composer-install

# Run pending migrations
./craft migrate/all --no-backup

# Commented out by erosas for debugging purposes
# # Apply changes from project config
# ./craft project-config/apply

# https://docs.docker.com/engine/reference/builder/#exec-form-entrypoint-example
exec "$@"