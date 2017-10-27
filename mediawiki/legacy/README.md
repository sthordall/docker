# MediaWiki

```bash
mkdir -p mediawiki/data
mkdir -p mediawiki/images
docker run -d --name mediawiki \
  -p 8080:80 \
  -v $(pwd)/mediawiki/data:/var/www/data \
  -v $(pwd)/mediawiki/images:/var/www/html/images \
  kuznero/mediawiki:legacy
```

For the very first time when you run `kuznero/mediawiki:legacy` you will be
prompted to perform initial configuration of you `mediawiki` instance. In the
end of this process you will be able to download `LocalSettings.php` file. This
file contains all the settings that you have chosen. In order to apply these
settings you will only need to copy it into `$(pwd)/mediawiki/data` and restart
your container.
