
dockerized php, ready for mediawiki installations

## docker-compose.yml

```yml
version: "2"
 services:
  wiki:
   image: buckaroobanzay/php
   restart: always
   depends_on:
    - "postgres"
   volumes:
    - "./data/wiki:/var/www/html/wiki"
   logging:
    options:
     max-size: 50m
```
