FROM webdevops/php-nginx:8.0-alpine

ENV WEB_DOCUMENT_ROOT=/app/public
ENV php.opcache.enable=1
ENV php.opcache.memory_consumption=512
ENV php.opcache.interned_strings_buffer=64
ENV php.opcache.max_accelerated_files=32531
ENV php.opcache.fast_shutdown=0
ENV FPM_PM_MAX_CHILDREN=20
ENV FPM_MAX_REQUESTS=1000

RUN apk --update --no-cache add \
    autoconf \
    gcc \
    g++ \
    make \
    librdkafka-dev \
    less

RUN pecl install rdkafka && docker-php-ext-enable rdkafka

WORKDIR /app
USER 1000
