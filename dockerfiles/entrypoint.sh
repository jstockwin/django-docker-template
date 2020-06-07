#!/bin/bash
set -e

# Wait for PostgreSQL connection before continuing
until nc -z -v -w30 $POSTGRESQL_HOST $POSTGRESQL_PORT
do
    echo "Waiting for database connection on $POSTGRESQL_HOST:$POSTGRESQL_PORT..."
    sleep 1
done
echo "Database connection available"

echo "Apply migrations"
# Migrations must be run as appuser user to prevent any permission issues
/app/app/manage.py migrate


if [[ "$ENVIRONMENT" = "production" ]]; then
    ########################################
    #       Production related setup       #
    ########################################

    # Remove default site configuration
    [[ -e /etc/nginx/sites-enabled/default ]] && rm /etc/nginx/sites-enabled/default
    [[ -e /etc/nginx/sites-available/default ]] && rm /etc/nginx/sites-available/default

    # Link app related config file from sites available to sites enabled and
    # restart Nginx
    ln -sf /etc/nginx/sites-available/app_nginx.conf /etc/nginx/sites-enabled/app_nginx.conf
    service nginx restart

    # Collect static files
    /app/app/manage.py collectstatic --noinput
    chown -R appuser:appuser /app/app

    # Run uwsgi
    uwsgi --ini /app/uwsgi.ini
fi

eval "$@"
