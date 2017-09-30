#!/usr/bin/env bash

if [ ! -z "$WG_SERVER" ]; then
  sed -i "s/wgServer = \"\"/wgServer = \"${WG_SERVER//\//\\\/}\"/" /var/www/html/LocalSettings.php
fi

if [ ! -z "$WG_SITENAME" ]; then
  sed -i "s/wgSitename = \"\"/wgSitename = \"${WG_SITENAME//\//\\\/}\"/" /var/www/html/LocalSettings.php
fi

if [ ! -z "$WG_META_NAMESPACE" ]; then
  sed -i "s/wgMetaNamespace = \"\"/wgMetaNamespace = \"${WG_META_NAMESPACE//\//\\\/}\"/" /var/www/html/LocalSettings.php
fi

if [ ! -z "$WG_LOGO" ]; then
  sed -i "s/wgLogo = \"\"/wgLogo = \"${WG_LOGO//\//\\\/}\"/" /var/www/html/LocalSettings.php
fi

docker-php-entrypoint apache2-foreground
