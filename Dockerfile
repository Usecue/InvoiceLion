FROM php:apache-buster

RUN apt-get update && \
    apt-get install -y \
        libmemcached-dev \
        zlib1g-dev \
        unzip \
        && \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install mysqli && \
    pecl install memcache && \
    docker-php-ext-enable memcache && \
    a2enmod rewrite

ADD https://getcomposer.org/composer.phar /usr/bin/composer

COPY . /var/www/html/.
WORKDIR /var/www/html/

RUN chmod +x /usr/bin/composer && \
    composer install

RUN cd /var/www/html/ && \
    rm *.sql && \
    rm *.sh && \
    cat config/config.php.template config/config.php.docker > config/config.php
