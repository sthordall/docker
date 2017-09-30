FROM mediawiki:stable
# base image does not come with python installed :(
RUN apt-get update && apt-get install -y python --no-install-recommends && rm -r /var/lib/apt/lists/*
VOLUME /var/www/data
ADD init.sh /var/www/html
ENTRYPOINT ["./init.sh"]
