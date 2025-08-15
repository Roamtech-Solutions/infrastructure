#!/bin/sh
set -e

# Run migrations
# -----------------------------------------------------------
# Ensure the database schema is up to date.
# -----------------------------------------------------------
./vendor/bin/phinx migrate

# Run the default command
exec "$@"
