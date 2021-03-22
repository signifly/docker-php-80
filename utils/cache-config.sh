#!/bin/sh

. /utils/vault-env.sh

if [ -z "${DEV}" ]
then
  if [ -f "${WORK_DIR}/artisan" ]
  then
    echo "Caching application"
    php ${WORK_DIR}/artisan optimize
    php ${WORK_DIR}/artisan view:cache

  else
    echo "Artisan not present"
  fi
fi
