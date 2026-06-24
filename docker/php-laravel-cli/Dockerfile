ARG PHP_VERSION=8.4

# Stage 1: Build environment and Composer dependencies
FROM php:${PHP_VERSION}-cli AS builder

# Install system dependencies and PHP extensions required for Laravel + MySQL/PostgreSQL support
# Some dependencies are required for PHP extensions only in the build stage
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

# Copy the entire Laravel application code into the container
COPY . /var/www

# Install Composer and dependencies
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-dev --optimize-autoloader --no-interaction --no-progress --prefer-dist

# Stage 2: Production environment
FROM php:${PHP_VERSION}-cli

RUN docker-php-ext-install pcntl

# Install system dependencies and PHP extensions for Laravel with MySQL/PostgreSQL support.
# Dependencies in this stage are only required for building the final image.
# Node.js and asset building are handled in the Nginx stage, not here.
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync
# Only install opentelemetry when PHP version >= 8.0
RUN phpv=$(printf "${PHP_VERSION}\n8.0" | sort -V | tail -1); \
	(test "${PHP_VERSION}" = "8.0" || test "${phpv}" != "8.0") \
	&& install-php-extensions http opentelemetry \
	|| install-php-extensions http 

# Install client libraries required for php extensions in runtime
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

# Install Kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
	&& install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Copy PHP extensions and libraries from the builder stage
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/bin/docker-php-ext-* /usr/local/bin/

# Use the default production configuration for PHP runtime arguments
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copy the application code and dependencies from the build stage
COPY --from=builder /var/www /var/www

# Set working directory
WORKDIR /var/www

# Ensure correct permissions
RUN chown -R www-data:www-data /var/www

# Make sure PHP can acces variables
RUN sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"\nclear_env = no/g' /usr/local/etc/php/php.ini

# Switch to the non-privileged user to run the application
USER www-data

# Default command: Provide a bash shell to allow running any command
CMD ["bash"]
