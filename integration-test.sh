#!/bin/bash

# build
docker build . -t php-docker

# setup
docker run --name php-docker --rm \
 --net host \
 -v $(pwd)/test:/var/www/html/wiki \
 php-docker &

# wait for http server start
sleep 2

function cleanup {
	# cleanup
	docker stop php-docker
  docker network rm php-docker
}

trap cleanup EXIT

curl http://127.0.0.1:8080/ || exit 1

# TODO: proper testing

echo "Test complete!"
