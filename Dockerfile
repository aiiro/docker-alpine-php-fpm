FROM php:7.0-fpm-alpine

RUN \
  apk add --no-cache \
          autoconf \
          file \
          freetype \
          g++ \
          gcc \
          imagemagick \
          libbz2 \
          libintl \
          libltdl \
          libjpeg-turbo \
          libmcrypt \
          libpng \
          libtool \
          make \

  && apk add --no-cache --virtual .dev-deps \
          libmcrypt-dev \
          freetype-dev \
          imagemagick-dev \
          libjpeg-turbo-dev \
          libpng-dev \
          libxml2-dev \

  && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \

  && docker-php-ext-install -j${NPROC} bz2 \

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
        openssl \
        tokenizer \
        zip \

  # Install Imagick
  && pecl install imagick \
  && docker-php-ext-enable imagick \

  # Install Composer
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
  && chown www-data:www-data /usr/bin/composer \

  && apk del .dev-deps autoconf g++ libtool make

ADD container-files /

RUN /bin/sh /config/init/php-init.sh

WORKDIR /data/www/html

EXPOSE 9000

CMD ["php-fpm"]
