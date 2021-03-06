FROM php:7.4.15-fpm

#Install Libraries
RUN apt-get update && \
    apt-get install -y \
        libzip-dev \
        libjpeg-dev \
        libpng-dev \
        libxpm-dev \
        libfreetype6-dev \
        libonig-dev \
        libicu-dev \
        libsqlite3-0 \
        libsqlite3-dev \
        libssl-dev \
        libz-dev \
        libxml2-dev

# PHP Installation
RUN docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install gd mysqli pdo pdo_mysql mysqli json soap xml opcache zip mbstring intl ftp bcmath \
    && pecl install xdebug redis && docker-php-ext-enable xdebug redis

# Nginx Installation
RUN  apt update && apt install wget gnupg gnupg2 -y && \
    echo "deb https://nginx.org/packages/mainline/debian/ buster nginx" >> /etc/apt/sources.list && \
    echo "deb-src https://nginx.org/packages/mainline/debian/ buster nginx" >> /etc/apt/sources.list && \
    cd /tmp && \
    wget https://nginx.org/keys/nginx_signing.key && \
    apt-key add nginx_signing.key && \
    apt update && apt install nginx supervisor procps -y && \
    apt-get clean -y

# New Relic Installation
RUN cd /opt/ && \
    wget https://download.newrelic.com/php_agent/release/newrelic-php5-9.16.0.295-linux.tar.gz -O newrelic-php5-9.16.0.295-linux.tar.gz && \
    tar -xzf newrelic-php5-9.16.0.295-linux.tar.gz && \
    cd /opt/newrelic-php5-9.16.0.295-linux && \
    ./newrelic-install install

# COPY Configs
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx-vhost.conf /etc/nginx/conf.d/default.conf
COPY config/www.conf /usr/local/etc/php-fpm.d/
COPY config/php.ini /usr/local/etc/php/conf.d/
COPY config/newrelic.ini /usr/local/etc/php/conf.d/
COPY config/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/

EXPOSE 80

VOLUME ["/www"]
WORKDIR /www

CMD ["/usr/bin/supervisord"]