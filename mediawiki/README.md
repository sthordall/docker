# MediaWiki

```bash
mkdir data
docker run -d --name mediawiki \
  -p 8080:80 \
  -v $(pwd)/data:/var/www/data \
  kuznero/mediawiki
```

For the very first time when you run `kuznero/mediawiki` you will be prompted to
perform initial configuration of you `mediawiki` instance. In the end of this
process you will be able to download `LocalSettings.php` file. This file
contains of the settings that you have chosen. In order to apply these settings
you will only need to copy it into `$(pwd)/data` and restart your container.
