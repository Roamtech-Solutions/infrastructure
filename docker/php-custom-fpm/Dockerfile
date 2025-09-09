ARG PHP_VERSION=8.4

FROM php:${PHP_VERSION}-fpm

# Install only runtime libraries needed in production
# libfcgi-bin and procps are required for the php-fpm-healthcheck script
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    libicu-dev \
    libzip-dev \
    libfcgi-bin \
    procps \
    && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and install php-fpm health check script
RUN curl -o /usr/local/bin/php-fpm-healthcheck \
    https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
    && chmod +x /usr/local/bin/php-fpm-healthcheck

# Copy the initial storage structure
#COPY ./storage /var/www/storage-init

# Copy PHP extensions and libraries from the builder stage
#COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
#COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
#COPY --from=builder /usr/local/bin/docker-php-ext-* /usr/local/bin/

# Use the recommended production PHP configuration
# -----------------------------------------------------------
# PHP provides development and production configurations.
# Here, we replace the default php.ini with the production
# version to apply settings optimized for performance and
# security in a live environment.
# -----------------------------------------------------------
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Enable PHP-FPM status page by modifying zz-docker.conf with sed
RUN sed -i '/\[www\]/a pm.status_path = /status' /usr/local/etc/php-fpm.d/zz-docker.conf
# Update the variables_order to include E (for ENV)
#RUN sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' "$PHP_INI_DIR/php.ini"


# Make sure PHP can acces variables
RUN sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"\nclear_env = no/g' /usr/local/etc/php/php.ini

# Stop errors about max children being exceeded
RUN sed -i '/^pm.max_children/c\pm.max_children = 32' /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www

COPY . /var/www/public

# Ensure correct permissions
RUN chown -R www-data:www-data /var/www

# Switch to the non-privileged user to run the application
USER www-data

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]

