FROM php:7-fpm

# Install dependencies
USER root 
RUN apt-get update && apt-get -qq install libpq-dev libmagickwand-dev libzip-dev libmemcached-dev jq libonig-dev nginx nginx-extras supervisor
RUN pecl install imagick memcached && \
    docker-php-ext-install -j "$(nproc)" opcache iconv bcmath mbstring pdo_pgsql gd zip intl \
    && docker-php-ext-enable imagick memcached

# Configure PHP
RUN sed -ri -e 's/memory_limit = 128M/memory_limit = 256M/' $PHP_INI_DIR/php.ini-production  && \
    sed -ri -e 's/max_execution_time = 30/max_execution_time = 120/' $PHP_INI_DIR/php.ini-production && \
    mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

# Tell CraftCMS to stream logs to stdout/stderr. https://craftcms.com/docs/3.x/config/#craft-stream-log
ENV CRAFT_STREAM_LOG true

# Configure Nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /usr/local/etc/php-fpm.d/zz-docker.conf

# Configure supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN rm /var/www/html/index.nginx-debian.html && chown -R www-data:www-data /var/www /run

# Add the www-data user to the tty group so it can write to stdout and stderr
RUN usermod -aG tty www-data

USER www-data

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf" ]