FROM mediawiki:stable
# base image does not come with python installed :(
RUN apt-get update && apt-get install -y python --no-install-recommends && rm -r /var/lib/apt/lists/*
ADD LocalSettings.php /var/www/html
VOLUME /var/www/data
EXPOSE 80
