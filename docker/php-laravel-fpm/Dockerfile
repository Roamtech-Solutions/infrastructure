ARG PHP_VERSION=8.4

# Stage 1: Build environment and Composer dependencies
FROM php:${PHP_VERSION}-fpm AS builder

# Install system dependencies and PHP extensions for Laravel with MySQL/PostgreSQL support.
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync
# Only install opentelemetry when PHP version >= 8.0
RUN phpv=$(printf "${PHP_VERSION}\n8.0" | sort -V | tail -1); \
	(test "${PHP_VERSION}" = "8.0" || test "${phpv}" != "8.0") \
	&& install-php-extensions http opentelemetry \
	|| install-php-extensions http 

RUN docker-php-ext-install pcntl

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    libpq-dev \
    libonig-dev \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    opcache \
    intl \
    zip \
    bcmath \
    soap \
    sockets \
    gd \
    exif

# Only install redis via pecl when PHP version >= 7.4
RUN phpv=$(printf "${PHP_VERSION}\n7.4" | sort -V | tail -1); \
	(test "${PHP_VERSION}" = "7.4" || test "${phpv}" != "7.4") \
	&& (pecl install redis && docker-php-ext-enable redis) \
	|| echo "PHP version too low to install pecl redis"

RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the working directory inside the container
WORKDIR /var/www

# Copy the entire application code into the container
COPY . /var/www

# Install Composer and dependencies
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-dev --optimize-autoloader --no-interaction --no-progress --prefer-dist

# Stage 2: Production environment
FROM php:${PHP_VERSION}-fpm

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN docker-php-ext-install pcntl

RUN chmod +x /usr/local/bin/install-php-extensions && sync
# Only install opentelemetry when PHP version >= 8.0
RUN phpv=$(printf "${PHP_VERSION}\n8.0" | sort -V | tail -1); \
	(test "${PHP_VERSION}" = "8.0" || test "${phpv}" != "8.0") \
	&& install-php-extensions http opentelemetry \
	|| install-php-extensions http 

# Install runtime libraries needed in production
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    libpq-dev \
    libonig-dev \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    opcache \
    intl \
    zip \
    bcmath \
    soap \
    sockets \
    gd \
    exif

# Download and install php-fpm health check script
RUN curl -o /usr/local/bin/php-fpm-healthcheck \
    https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
    && chmod +x /usr/local/bin/php-fpm-healthcheck

# Copy the initialization script
COPY ./docker/php-laravel-fpm/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy the initial storage structure
COPY ./storage /var/www/storage-init

# Copy PHP extensions and libraries from builder
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/bin/docker-php-ext-* /usr/local/bin/

# Use production PHP configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copy application code and dependencies from builder stage
COPY --from=builder /var/www /var/www

# Set working directory
WORKDIR /var/www

# Ensure all required storage and cache directory structures exist
RUN mkdir -p storage/framework/cache/data \
             storage/framework/sessions \
             storage/framework/views \
             storage/logs \
             bootstrap/cache

# Trick Crater into thinking it is already installed and DB is set up
RUN mkdir -p storage/app && touch storage/app/installed storage/app/database_created

# Ensure correct ownership (www-data) and 775 directory permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Ensure correct ownership (www-data) and 775 directory permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Make sure PHP can access environment variables
RUN sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"\nclear_env = no/g' /usr/local/etc/php/php.ini

COPY docker/php-laravel-fpm/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY docker/php-laravel-fpm/php-fpm.conf /usr/local/etc/php-fpm.conf

# Switch to non-privileged user
USER www-data

# Set entrypoint and default command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 9000
CMD ["php-fpm"]
