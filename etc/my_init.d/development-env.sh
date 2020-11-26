#!/bin/bash

if [[ -n "${INSTALL_DEPENDENCIES}" ]]
then
  /utils/composer.sh
fi

if [[ -n "${MIGRATE_ON_STARTUP}" ]]
then
  php ${WORK_DIR}/artisan migrate --force
fi

if [[ -n "${DEV}" ]]
then
  if [[ -f "${WORK_DIR}/artisan" ]]
  then
    echo "Clearing caches"
    php ${WORK_DIR}/artisan cache:clear
    php ${WORK_DIR}/artisan config:clear
    php ${WORK_DIR}/artisan optimize:clear
    php ${WORK_DIR}/artisan view:clear
    php ${WORK_DIR}/artisan route:clear
  else
    echo "Artisan not present"
  fi

  /utils/autoloader.sh
fi
