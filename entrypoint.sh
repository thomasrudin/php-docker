#!/bin/sh

# migration script
test -f LocalSettings.php && php maintenance/update.php -q


#docker-php-entrypoint
apache2-foreground
