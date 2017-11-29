FROM mediawiki:stable
VOLUME /var/www/data
VOLUME /var/www/html/images
ADD init.sh /var/www/html
ADD images /var/www/html/images-init
ENTRYPOINT ["./init.sh"]
