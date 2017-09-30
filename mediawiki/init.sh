#!/usr/bin/env bash

chown -R www-data:www-data /var/www/data

if [ -f "/var/www/data/LocalSettings.php" ]; then
  echo Applying local settings ...
  cp -v /var/www/data/LocalSettings.php /var/www/html
  chown www-data:www-data /var/www/html/LocalSettings.php
  echo "done."
fi

docker-php-entrypoint apache2-foreground
