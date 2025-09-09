# Stage 1: Build assets
FROM debian AS builder

# Install Node.js and build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    nodejs \
    npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set working directory
WORKDIR /var/www

# Stage 2: Nginx production image
FROM nginx:alpine

# Copy custom Nginx configuration
# -----------------------------------------------------------
# Replace the default Nginx configuration with our custom one
# that is optimized for serving a Laravel application.
# -----------------------------------------------------------
COPY ./docker/php-custom-nginx/nginx.conf /etc/nginx/nginx.conf

# Set the working directory to the public folder
WORKDIR /var/www

# Expose port 8080 and start Nginx
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

