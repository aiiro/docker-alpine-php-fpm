#!/bin/sh

set -e

mkdir -p /data/tmp/php/uploads
mkdir -p /data/tmp/php/sessions
chown -R www-data:www-data /data/tmp/php

mkdir -p /data/logs
mkdir -p /data/www/html/public
