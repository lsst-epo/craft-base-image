FROM craftcms/nginx:7.4

USER root

RUN apk add --no-cache \
  libpq-dev \
  libpng-dev \
  imagemagick \
  libzip-dev \
  libmemcached-dev \
  jq \
  icu-dev \
  oniguruma-dev \
  autoconf \
  g++ \
  make
# RUN apt-get update && apt-get -qq install \
#   libpq-dev \
#   libmagickwand-dev \
#   libzip-dev \
#   libmemcached-dev \
#   jq \
#   libonig-dev \
#   && rm -rf /var/lib/apt/lists/*
RUN pecl install \
  imagick \
  memcached \
  xdebug \
  && docker-php-ext-install -j "$(nproc)" bcmath mbstring pdo_pgsql gd zip intl \
  && docker-php-ext-enable imagick memcached xdebug

  USER www-data

# # Use the PORT environment variable in Apache configuration files.
# # https://cloud.google.com/run/docs/reference/container-contract#port
# RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf && \
#     sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/web/g' /etc/apache2/sites-available/000-default.conf && \
#     a2enmod rewrite headers && \
#     # The next line disables gzip compression. Added on 7/19/22 by Jared Trouth for troubleshooting.
#     a2dismod -f deflate

# COPY php.ini-production "$PHP_INI_DIR/php.ini"

# COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
# COPY docker-entrypoint.sh /

# ENTRYPOINT [ "/docker-entrypoint.sh" ]

# CMD [ "apache2-foreground" ]
