FROM php:7.1-fpm-alpine

RUN \
  apk add --no-cache \
          autoconf \
          curl \
          file \
          freetype \
          g++ \
          gcc \
          icu \
          icu-libs \
          imagemagick \
          libbz2 \
          libcurl \
          libintl \
          libltdl \
          libjpeg-turbo \
          libmcrypt \
          libpng \
          libtool \
          openssl \
          make \

  && apk add --no-cache --virtual .dev-deps \
          bzip2-dev \
          curl-dev \
          libmcrypt-dev \
          freetype-dev \
          icu-dev \
          imagemagick-dev \
          libjpeg-turbo-dev \
          libpng-dev \
          libxml2-dev \
          openssl-dev \

  && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \

  && docker-php-ext-install -j${NPROC} bz2 \

  && docker-php-ext-configure intl \
  && docker-php-ext-install -j${NPROC} intl \

  && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
  && docker-php-ext-install -j${NPROC} gd \

  && docker-php-ext-configure pdo_mysql \
        --with-pdo-mysql=mysqlnd \
  && docker-php-ext-install -j${NPROC} pdo_mysql \

  && docker-php-ext-configure mysqli \
        --with-mysqli=mysqlnd \
  && docker-php-ext-install -j${NPROC} mysqli \

  && docker-php-ext-install -j${NPROC} \
        curl \
        iconv \
        mcrypt \
        opcache \
        tokenizer \
        zip \

  # Install pecl libraries
  && pecl install xdebug \
  && docker-php-ext-enable xdebug \

  # Setting xdebug
  && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \

  # Install Composer
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
  && chown www-data:www-data /usr/bin/composer \

  && apk del .dev-deps autoconf g++ libtool make

ADD container-files /

RUN /bin/sh /config/init/php-init.sh

WORKDIR /data/www/html

EXPOSE 9000

CMD ["php-fpm"]
