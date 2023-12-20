# Use the official PHP image.
# https://hub.docker.com/_/php
FROM php:8.2-apache

# Configure PHP for Cloud Run.
# Precompile PHP code with opcache.
RUN docker-php-ext-install -j "$(nproc)" opcache
# RUN docker-php-ext-install -j "$(nproc)" memcache
RUN set -ex; \
  { \
    # echo "memory_limit = 256M"; \
    # echo "max_execution_time = 300"; \
    # echo "upload_max_filesize = 32M"; \
    # echo "post_max_size = 32M"; \
    echo "; Configure Opcache for Containers"; \
    echo "opcache.enable = On"; \
    echo "opcache.validate_timestamps = Off"; \
    echo "; Configure Opcache Memory (Application-specific)"; \
    echo "opcache.memory_consumption = 128"; \
  } > "$PHP_INI_DIR/conf.d/app-engine.ini"


RUN apt-get update && apt-get -qq install \
  libpq-dev \
  libmagickwand-dev \
  libzip-dev \
  libmemcached-dev \
  memcached \
  jq \
  libonig-dev \
  python3.10 \
  pip \
  && rm -rf /var/lib/apt/lists/*

RUN pip install supervisor --break-system-packages
COPY supervisord.conf /etc/supervisord.conf

RUN pecl install \
  imagick \
  memcached \
  memcache \
  redis \
  xdebug \
  zlib
RUN docker-php-ext-install -j "$(nproc)" iconv bz2 bcmath mbstring pdo_pgsql gd zip intl
RUN docker-php-ext-enable imagick memcached redis xdebug

RUN php -m

# Use the PORT environment variable in Apache configuration files.
# https://cloud.google.com/run/docs/reference/container-contract#port
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf && \
    sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/web/g' /etc/apache2/sites-available/000-default.conf && \
    a2enmod rewrite headers

COPY php.ini-production "$PHP_INI_DIR/php.ini"

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "apache2-foreground" ]
