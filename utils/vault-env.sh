#!/usr/bin/env bash

# automatically export all sourced variables
set -a

if [ -d "/vault" ]
then
    echo "Vault present, loading env variables"
    for f in /vault/secrets/*; do
       echo "Loading: $f"
       . $f
    done
else
    echo "Vault not present"
fi
