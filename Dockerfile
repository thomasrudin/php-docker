FROM mediawiki:1.34.4

RUN apt-get update && apt-get install -y \
  libonig-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libjpeg-dev \
  libmcrypt-dev \
  libmemcached-dev \
  libpng-dev \
  libpq-dev \
  sendmail

RUN docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql pdo_pgsql pgsql \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && pecl install memcached \
    && docker-php-ext-enable memcached

COPY php.ini $PHP_INI_DIR/conf.d/custom.ini
COPY entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
