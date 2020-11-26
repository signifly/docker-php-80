ARG BASE_IMAGE=ubuntu:18.04

FROM microsoft/mssql-tools as mssql
FROM $BASE_IMAGE
MAINTAINER Signifly <dev@signifly.com>

ARG PHP_VERSION=7.4

ENV TZ=Europe/Copenhagen \
    DEBIAN_FRONTEND=noninteractive \
    PHP_VERSION=${PHP_VERSION} \
    COMPOSER_ALLOW_SUPERUSER=1 \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="32531" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="256" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10" \
    PHP_OPCACHE_INTERNED_STRINGS_BUFFER="16" \
    PHP_OPCACHE_ENABLE="1" \
    PHP_UPLOAD_MAX_SIZE="100M" \
    PHP_FILE_UPLOADS="On" \
    PHP_MAX_EXECUTION_TIME="30" \
    FASTCGI_READ_TIMEOUT="60" \
    WORK_DIR="/var/www/html" \
    OPCACHE_VERSION="3" \
    COMPOSER_HOME="/.composer" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8" \
    PHP_PM="static" \
    PHP_PM_MAX_CHILDREN="10" \
    ROLE="app"

COPY . /

RUN /bd_build/prepare.sh && \
	/bd_build/system_services.sh && \
	/bd_build/utilities.sh && \
    /bd_build/php.sh && \
    /bd_build/prepare-runtime.sh && \
	/bd_build/cleanup.sh

ENV DEBIAN_FRONTEND="teletype"
WORKDIR $WORK_DIR

CMD ["/sbin/my_init"]
