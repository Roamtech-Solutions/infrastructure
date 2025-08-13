FROM php:8.1-fpm-alpine

RUN apk add --no-cache \
    autoconf \
    gcc \
    g++ \
    make \
    zlib-dev \
    libzip-dev \
    mysql-client \
    mysql-dev # Install MySQL client and development libraries for pdo_mysql extension

RUN docker-php-ext-install zip sockets pdo_mysql # Add pdo_mysql to the installation

RUN pecl install redis \
    && docker-php-ext-enable redis

# Install Composer
ENV COMPOSER_HOME /composer
ENV PATH $COMPOSER_HOME/vendor/bin:$PATH
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

EXPOSE 9000
CMD ["php-fpm"]

