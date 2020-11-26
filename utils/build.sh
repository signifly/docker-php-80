#!/bin/bash

if [ -f "${WORK_DIR}/artisan" ]
then
  echo "Caching application"
  php ${WORK_DIR}/artisan optimize
  php ${WORK_DIR}/artisan view:cache

  if [ -d "${WORK_DIR}/vendor/laravel/horizon" ]
  then
    echo "Publishing horizon assets"
    php ${WORK_DIR}/artisan horizon:publish
  else
    echo "Horizon not present"
  fi
else
  echo "Artisan not present"
fi
