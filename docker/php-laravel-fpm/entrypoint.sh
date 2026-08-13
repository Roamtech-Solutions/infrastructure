#!/bin/sh
set -e

# Initialize storage directory if empty
# -----------------------------------------------------------
if [ -d "/var/www/storage-init" ]; then
	if [ ! "$(ls -A /var/www/storage 2>/dev/null)" ]; then
		echo "Initializing storage directory..."
		cp -R /var/www/storage-init/. /var/www/storage
	fi
	rm -rf /var/www/storage-init
fi

# Ensure all required framework directories exist at runtime
# -----------------------------------------------------------
mkdir -p /var/www/storage/framework/cache/data \
         /var/www/storage/framework/sessions \
         /var/www/storage/framework/views \
         /var/www/storage/logs \
         /var/www/bootstrap/cache

# Enforce 775 permissions on storage and cache folders
chmod -R 775 /var/www/storage /var/www/bootstrap/cache 2>/dev/null || true

# Clear and cache configurations
# -----------------------------------------------------------
if grep -q -i 'lumen' composer.json 2>/dev/null || [ "${PHP_CONFIG_CACHE_SKIP}" = "true" ]; then
	echo "Laravel Lumen project or cache skip enabled - Skipping config and route cache"
else
	php artisan config:cache && php artisan route:cache
fi

# Run the default command
exec "$@"
