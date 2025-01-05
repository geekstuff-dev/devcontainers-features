#!/bin/sh

echo "create shared cache target folder: $SHARED_CACHE"

mkdir -p $SHARED_CACHE
chown -R ${_CONTAINER_USER}: $SHARED_CACHE
