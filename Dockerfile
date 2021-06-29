FROM mediawiki:1.36.1

# install deps
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

# add php extensions
RUN docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql pdo_pgsql pgsql \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && pecl install memcached \
    && docker-php-ext-enable memcached

# add mediawiki extensions
COPY extensions/SimpleEmbed /var/www/html/extensions/SimpleEmbed
RUN cd /var/www/html/extensions/ &&\
  git clone --depth=1 https://github.com/wikimedia/mediawiki-extensions-MsUpload MsUpload  -b REL1_36 &&\
  git clone --depth=1 https://github.com/wikimedia/mediawiki-extensions-TemplateStyles TemplateStyles -b REL1_36 &&\
  git clone --depth=1 https://github.com/ProfessionalWiki/SimpleBatchUpload -b 1.8.2 &&\
  git clone --depth=1 https://github.com/cmln/mw-font-awesome/ -b 1.0 FontAwesome &&\
  git clone --depth=1 https://github.com/DaSchTour/matomo-mediawiki-extension Matomo -b v4.0.0 &&\
  git clone --depth=1 https://github.com/kulttuuri/DiscordNotifications.git -b 1.12 &&\
  # js slideshow
  git clone https://gitlab.com/hydrawiki/extensions/javascriptslideshow JavascriptSlideshow &&\
  cd JavascriptSlideshow && git checkout 62e5de29579e5764783641c6fd471f45d3770a05 && cd .. &&\
  # minetest auth proxy
  git clone --depth=1 https://github.com/minetest-auth-proxy/auth_proxy_app &&\
  ln -s auth_proxy_app/mediawiki/AuthMinetest/


COPY php.ini $PHP_INI_DIR/conf.d/custom.ini
COPY entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
