FROM mediawiki:stable
# base image does not come with python installed :(
RUN apt-get update && apt-get install -y python --no-install-recommends && rm -r /var/lib/apt/lists/*
VOLUME /var/www/data
ADD LocalSettings.php /var/www/html
ADD data /var/www/data_init
ADD init.sh /var/www/html
ENV WG_SERVER=http://127.0.0.1:8080
ENV WG_SITENAME="Team Name"
ENV WG_META_NAMESPACE=Team_Name
ENV WG_LOGO="\$wgResourceBasePath/resources/assets/wiki.png"
ENTRYPOINT ["./init.sh"]
