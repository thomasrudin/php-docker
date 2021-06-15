
Dockerized mediawiki


# Builtin extensions

* MsUpload
* TemplateStyles
* SimpleBatchUpload
* FontAwesome
* JavascriptSlideshow
* AuthMinetest
* SimpleEmbed
* Matomo
* DiscordNotifications

## Credentials for local testing

* Admin
* enterenter

## Local database

```bash
docker-compose up -d postgres
cat db.sql | docker exec -i mediawiki_postgres_1 psql -U postgres
docker-compose up wiki
```

Visit: http://localhost/index.php/Main_Page