#!/bin/bash
set -e

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
while ! mysql -h${DB_HOST:-zabbix-mysql} -u${DB_USER:-zabbix} -p${DB_PASSWORD:-zabbix_password} -e "SELECT 1" >/dev/null 2>&1; do
    echo "MySQL is not ready, waiting..."
    sleep 5
done

echo "MySQL is ready!"

# Check if Zabbix database is already initialized
DB_TABLES=$(mysql -h${DB_HOST:-zabbix-mysql} -u${DB_USER:-zabbix} -p${DB_PASSWORD:-zabbix_password} -e "USE ${DB_NAME:-zabbix}; SHOW TABLES;" 2>/dev/null | wc -l || echo "0")

if [ "$DB_TABLES" -lt "10" ]; then
    echo "Database appears to be empty, checking for zabbix.sql file..."

    if [ -f "/docker-entrypoint-initdb.d/zabbix.sql" ]; then
        echo "Importing existing zabbix.sql database..."
        mysql -h${DB_HOST:-zabbix-mysql} -u${DB_USER:-zabbix} -p${DB_PASSWORD:-zabbix_password} ${DB_NAME:-zabbix} < /docker-entrypoint-initdb.d/zabbix.sql
    else
        echo "Importing fresh Zabbix database schema..."
        # Import the official Zabbix schema
        zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -h${DB_HOST:-zabbix-mysql} -u${DB_USER:-zabbix} -p${DB_PASSWORD:-zabbix_password} ${DB_NAME:-zabbix}
    fi

    echo "Database import completed!"
else
    echo "Database already contains tables, skipping import."
fi

# Update Zabbix server configuration with environment variables
if [ ! -z "$DB_HOST" ]; then
    sed -i "s/DBHost=.*/DBHost=$DB_HOST/" /etc/zabbix/zabbix_server.conf
fi

if [ ! -z "$DB_NAME" ]; then
    sed -i "s/DBName=.*/DBName=$DB_NAME/" /etc/zabbix/zabbix_server.conf
fi

if [ ! -z "$DB_USER" ]; then
    sed -i "s/DBUser=.*/DBUser=$DB_USER/" /etc/zabbix/zabbix_server.conf
fi

if [ ! -z "$DB_PASSWORD" ]; then
    sed -i "s/DBPassword=.*/DBPassword=$DB_PASSWORD/" /etc/zabbix/zabbix_server.conf
fi

# Setup Nginx configuration
cp /etc/zabbix/nginx.conf /etc/nginx/sites-available/default

# Setup PHP-FPM configuration
cp /etc/zabbix/php-fpm.conf /etc/php/8.3/fpm/pool.d/zabbix.conf

# Create necessary directories
mkdir -p /var/log/supervisor
mkdir -p /var/run/php

# Set proper permissions
chown -R zabbix:zabbix /var/log/zabbix
chown -R zabbix:zabbix /var/run/zabbix

echo "Starting Zabbix services..."

# Execute the command passed to the container
exec "$@"