#!/bin/bash

param=""
if [ -z "${DEV}" ]; then
    param="--no-dev --prefer-dist"
fi

if [ ! -d "${WORK_DIR}/app" ]; then
    param="${param} --no-autoloader"
fi

composer install --no-interaction ${param} -d $WORK_DIR