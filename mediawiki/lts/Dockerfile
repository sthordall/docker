FROM mediawiki:lts
# base image does not come with python installed :(
RUN apt-get update && apt-get install -y python --no-install-recommends && rm -r /var/lib/apt/lists/*
VOLUME /var/www/data
VOLUME /var/www/html/images
ADD init.sh /var/www/html
ADD images /var/www/html/images-init
ENTRYPOINT ["./init.sh"]
