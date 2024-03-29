FROM composer:2.4.4 AS composer

FROM phpswoole/swoole:5.0-php8.1-alpine

RUN apk --update --no-cache add \
    gcompat \
    libstdc++ \
    git \
    wget \
    curl \
    build-base \
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
    libgcrypt-dev \
    librdkafka-dev \
    less

RUN pecl channel-update pecl.php.net && \
    pecl install mcrypt && \
    pecl install xdebug && \
    pecl install rdkafka &&  \
    pecl install redis &&  \
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
    docker-php-ext-enable xdebug && \
    docker-php-ext-enable rdkafka && \
    docker-php-ext-enable redis && \
    rm -rf /tmp/pear && \
    rm /var/cache/apk/*

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN adduser --shell /bin/sh --disabled-password --uid 1000 application
RUN mkdir /app && chown 1000:1000 -R /app

WORKDIR /app
USER 1000

EXPOSE 8000
