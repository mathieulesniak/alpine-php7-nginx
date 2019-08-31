#!/bin/sh
echo "[i] Fixing permissions & ownership..."
# find /var/www/ -type f -exec chmod 644 {} \; && find /var/www/ -type d -exec chmod 755 {} \;
chown -R nginx:nginx /var/www

echo "[i] Starting Prestashop..."

# start php-fpm
mkdir -p /usr/logs/php-fpm
php-fpm7

# start nginx
mkdir -p /usr/logs/nginx
mkdir -p /tmp/nginx
chown nginx /tmp/nginx
nginx
