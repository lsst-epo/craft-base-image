# CraftCMS Base Image #

This repository holds the sources for a container image that is capable of running Craft CMS in
a stateless containerized environment. The image is based off of the [php](https://hub.docker.com/_/php)
Docker community image, and installs nginx and certain PHP dependencies on top of that.

## Using the Base Image in a Project ##

This container should be used as a base (e.g. used in a `FROM` statement) for a Craft CMS application runtime container.

### Example Dockerfile ###

The below Dockerfile provides a basic example of using the Craft CMS base image. The image is
built in a 2-stage process using a composer container to install Craft dependencies, then the
application code and vendor packages are both copied into a container built from the base image. Additional steps or modifications my be needed depending on the specific app parameters. For example, if any local custom plugins are used then those will also need to be copied into the container.

```Dockerfile
# Composer dependencies
FROM composer:2 as vendor
COPY <CraftCMS_Folder_Name>/composer.json composer.json
COPY <CraftCMS_Folder_Name>/composer.lock composer.lock
RUN composer install --ignore-platform-reqs --no-interaction --prefer-dist

# Runtime container
FROM gcr.io/skyviewer/craft-base-image:latest

USER root 

# Copy in custom code from the host machine.
WORKDIR /var/www/html
COPY --chown=www-data:www-data <CraftCMS_Folder_Name>/ ./
COPY --from=vendor --chown=www-data:www-data /app/vendor /var/www/html/vendor
RUN [ -d /var/www/html/storage ] || mkdir /var/www/html/storage

# Make sure the www-data user has the correct directory ownership
RUN chown -R www-data:www-data /var/www /run /var/lib/nginx /var/log/nginx

USER www-data
```

## App compatability ##

Changes to the CraftCMS application will be necessary to utilize all of the
features available in this image (e.g. memcached session caching).

### Enable memcached ###

Craft is not configured to use memcached out of the box. The `config/app.php` file (or equivilant) needs to be updated to load in the memcached module. There is an example of this modification in the [CraftCMS Documentation](https://craftcms.com/docs/3.x/config/#memcached-example).

### (Optional) Relocate .env file ###

If you need to mount an .env file as a volume into the container it will
be necessary to update the `web/index.php` file to look for the file in the
correct path. The below example shows the changes needed to access the file
from a directoey bassed in the `SECRETS_DIR` environment variable (`/var/secrets/` by default)  .

```php
...

// Define path constants
define('CRAFT_BASE_PATH', dirname(__DIR__));
define('CRAFT_VENDOR_PATH', CRAFT_BASE_PATH . '/vendor');
define('SECRETS_DIR', '/var/secrets');

...

// Load dotenv?
if (class_exists('Dotenv\Dotenv') && file_exists(SECRETS_DIR . '/.env')) {
    Dotenv\Dotenv::create(SECRETS_DIR)->load();
}

...
```
