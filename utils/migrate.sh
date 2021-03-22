#!/usr/bin/env bash

echo 'Starting migration'

if [[ -d "/vault" ]]
then
    echo "Vault present, killing process"

    pkill vault
else
    echo "Vault not present"
fi


php ${WORK_DIR}/artisan migrate --force
