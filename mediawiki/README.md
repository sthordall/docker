# MediaWiki (with Sqlite backend)

```bash
mkdir data
docker run -d --name mediawiki \
  -p 8080:80 \
  -v $(pwd)/data:/var/www/data \
  -e WG_SERVER=http://127.0.0.1:8080 \
  -e WG_SITENAME="Team Name" \
  -e WG_META_NAMESPACE=Team_Name \
  -e WG_LOGO="\$wgResourceBasePath/resources/assets/mediawiki.png" \
  kuznero/mediawiki:sqlite
```
