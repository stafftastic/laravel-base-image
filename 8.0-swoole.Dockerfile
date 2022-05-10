FROM phpswoole/swoole:4.8.9-php8.0-alpine

RUN apk --update add \
        wget \
        curl \
        build-base \
        composer \
        nodejs \
        npm \
        libmcrypt-dev \
        libxml2-dev \
        pcre-dev \
        zlib-dev \
        autoconf \
        oniguruma-dev \
        openssl \
        openssl-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        jpeg-dev \
        libpng-dev \
        imagemagick-dev \
        imagemagick \
        postgresql-dev \
        libzip-dev \
        gettext-dev \
        libxslt-dev \
        libgcrypt-dev

RUN pecl channel-update pecl.php.net && \
    pecl install mcrypt && \
    docker-php-ext-install \
        mysqli \
        mbstring \
        pdo \
        pdo_mysql \
        tokenizer \
        xml \
        pcntl \
        bcmath \
        pdo_pgsql \
        zip \
        intl \
        gettext \
        soap \
        sockets \
        xsl && \
    docker-php-ext-configure gd --with-freetype=/usr/lib/ --with-jpeg=/usr/lib/ && \
    docker-php-ext-install gd && \
    rm -rf /tmp/pear && \
    rm /var/cache/apk/*

WORKDIR /app
USER 1000

EXPOSE 80
