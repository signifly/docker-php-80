#!/bin/bash

if [ -d "${WORK_DIR}/vendor/laravel/horizon" ]
then
  php ${WORK_DIR}/artisan horizon:terminate
else
  php ${WORK_DIR}/artisan queue:restart
fi

while [ `ps aux | grep ":work" | wc -l` -gt 1 ];
do
  echo "Waiting for the queue to shutdown...";
  sleep 1
done

exit 0
