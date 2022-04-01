#!/bin/bash
set -e

# Install Craft plugins

if [ -f composer.json ]; then

    dependencies=$(cat composer.json |
        jq '.require' |
        jq --compact-output 'keys' |
        tr -d '[]"' | tr ',' '\n')

    for package in ${dependencies}; do

        echo $package

        vendor=$(awk -F '[\/:]+' '{print $1}' <<<$package)
        packageName=$(awk -F '[\/:]+' '{print $2}' <<<$package)
        isCraftPlugin=$(cat vendor/$vendor/$packageName/composer.json | jq '.type == "craft-plugin"')

        if [ "$isCraftPlugin" = true ]; then
            handle=$(cat vendor/$vendor/$packageName/composer.json | jq -r '.extra.handle')
            ./craft plugin/install $handle
        fi
    done
fi

# Ensure any pending migrations are run
./craft migrate/all

# Ensure the project config is set correctly
./craft project-config/apply

# https://docs.docker.com/engine/reference/builder/#exec-form-entrypoint-example
exec "$@"