# docker-alpine-php-fpm

## Usage
- docker run
```
docker run -d -v /data --name=php-data busybox
docker run -d --volumes-from php-data --name php-fpm aiiro/alpine-php-fpm:latest
```

