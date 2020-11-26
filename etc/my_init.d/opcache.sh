#!/bin/bash

if [ -z "${SKIP_OPCACHE}" ] && [ -d "${WORK_DIR}/vendor/appstract/laravel-opcache" ]
then
    # Hack to compile opcache after webserver has startet
    if [ "$OPCACHE_VERSION" = "2" ]; then
        sleep 10s && php ${WORK_DIR}/artisan opcache:optimize &
    fi
    if [ "$OPCACHE_VERSION" = "3" ]; then
        sleep 10s && php ${WORK_DIR}/artisan opcache:compile --force &
    fi
fi