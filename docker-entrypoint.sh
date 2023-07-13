#!/bin/bash
set -e

# Link Apache log files to output
ln -sf /proc/$$/fd/1 /var/log/apache2/access.log
ln -sf /proc/$$/fd/2 /var/log/apache2/error.log

# Install composer packages
./craft update/composer-install --interactive=0

# Run pending structural migrations
# ./craft migrate/all --no-backup --no-content --interactive=0

# Apply changes from project config yaml files
# ./craft project-config/apply --force

# Run pending content migrations
# ./craft migrate --track=content --interactive=0

# Clear caches
# ./craft clear-caches/all

# https://docs.docker.com/engine/reference/builder/#exec-form-entrypoint-example
exec "$@"