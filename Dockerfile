# Use the official PHP image.
# https://hub.docker.com/_/php
FROM php:7.4-apache

# Configure PHP for Cloud Run.
# Precompile PHP code with opcache.
RUN docker-php-ext-install -j "$(nproc)" opcache
RUN set -ex; \
  { \
    # echo "; Cloud Run enforces memory & timeouts"; \
    # echo "memory_limit = -1"; \
    # echo "max_execution_time = 0"; \
    # echo "; File upload at Cloud Run network limit"; \
    # echo "upload_max_filesize = 32M"; \
    # echo "post_max_size = 32M"; \
    echo "; Configure Opcache for Containers"; \
    echo "opcache.enable = On"; \
    echo "opcache.validate_timestamps = Off"; \
    echo "; Configure Opcache Memory (Application-specific)"; \
    echo "opcache.memory_consumption = 32"; \
  } > "$PHP_INI_DIR/conf.d/app-engine.ini"

RUN apt-get update && apt-get -qq install libpq-dev libmagickwand-dev libzip-dev libmemcached-dev jq libonig-dev
RUN pecl install imagick memcached xdebug && \
    docker-php-ext-install -j "$(nproc)" opcache iconv bcmath mbstring pdo_pgsql gd zip intl \
    && docker-php-ext-enable imagick memcached xdebug

# Use the PORT environment variable in Apache configuration files.
# https://cloud.google.com/run/docs/reference/container-contract#port
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf && \
    sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/web/g' /etc/apache2/sites-available/000-default.conf && \
    a2enmod rewrite headers

# Configure PHP for development.
# Switch to the production php.ini for production operations.
# RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
# https://github.com/docker-library/docs/blob/master/php/README.md#configuration
RUN mv php.ini-production "$PHP_INI_DIR/php.ini"

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "apache2-foreground" ]