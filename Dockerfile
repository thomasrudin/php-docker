FROM php:7.4.6-apache

RUN a2enmod rewrite

RUN apt-get update && apt-get install -y \
	libonig-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
	libjpeg-dev \
  libmcrypt-dev \
  libmemcached-dev \
  libpng-dev \
	libpq-dev \
  sendmail \
	python3

RUN docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd mbstring pdo pdo_mysql pdo_pgsql pgsql opcache \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
		&& pecl install apcu \
    && pecl install memcached \
    && docker-php-ext-enable memcached

COPY php.ini $PHP_INI_DIR/conf.d/custom.ini
