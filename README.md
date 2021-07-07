## PHP 8.0 base image

Example usage of this base image in projects:

```Dockerfile
FROM signifly/php-8.0:<version>

ARG BUILD_NUMBER
ARG BUILD_VERSION
ARG DEV
ENV BUILD_NUMBER ${BUILD_NUMBER}
ENV BUILD_VERSION ${BUILD_VERSION}
ENV DEV ${DEV}

USER www-data:www-data

RUN composer config --global --auth http-basic.repo.packagist.com token XXX
COPY --chown=www-data:www-data composer.json composer.lock $WORK_DIR/
RUN /utils/composer.sh
COPY --chown=www-data:www-data . $WORK_DIR/
RUN /utils/autoloader.sh

USER root
```

docker-compose.yml:
```
  app:
    container_name: XXX-api
    build: .
    environment:
      MYSQL_HOST: mysql
      DEV: 1
      PHP_OPCACHE_VALIDATE_TIMESTAMPS: 1
      MIGRATE_ON_STARTUP: 1
      INSTALL_DEPENDENCIES: 1
      SKIP_OPCACHE: 1
    labels:
      traefik.port: 80
      traefik.frontend.rule: Host:dev.signifly.io
    volumes:
      - ./:/var/www/html:delegated
      - ~/.composer/cache/:/.composer:cached

  horizon:
    container_name: XXX-api-horizon
    build: .
    environment:
      ROLE: "horizon"
    volumes:
      - ./:/var/www/html:delegated
      - ~/.composer/cache/:/.composer:cached
```


`OPCACHE_VERSION` can be set to `2` or `3` depending on which version is used. Defaults to "3".

`ROLE` env variable can be set to any of `[app, horizon, cron, websocket, migrate]`.

`PHP_FPM_CLEAR_ENV` can be set to `[yes, no]`. Defaults to `no`.

When setting the `ROLE` variable to `app`, it's also possible to set `RUN_CRON` to any value to start crontab in the background of the app container.
