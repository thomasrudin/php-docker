#!/bin/sh

# migration script
test -f LocalSettings.php && php maintenance/update.php


#docker-php-entrypoint
apache2-foreground
