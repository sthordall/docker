#!/usr/bin/env bash

chown -R www-data:www-data /var/www/data

if [ -f "/var/www/data/LocalSettings.php" ]; then
  echo Applying local settings ...
  cp -v /var/www/data/LocalSettings.php /var/www/html
  chown www-data:www-data /var/www/html/LocalSettings.php
  echo "done."
fi

chown -R www-data:www-data /var/www/html/images-init
chown -R www-data:www-data /var/www/html/images

if [ ! -f "/var/www/html/images/.htaccess" ]; then
  echo Fixing images ...
  cp -v /var/www/html/images-init/.htaccess /var/www/html/images/
  echo "done."
fi

docker-php-entrypoint apache2-foreground
