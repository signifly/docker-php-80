#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

# Prevent nginx installation from fucking up
mv /etc/nginx /nginx-tmp

apt-get -q update && apt-get -qy install --no-install-recommends php${PHP_VERSION}-fpm php${PHP_VERSION}-dev \
  php-pcov \
  php${PHP_VERSION}-gd \
  php${PHP_VERSION}-imagick \
  php${PHP_VERSION}-bcmath \
  php${PHP_VERSION}-bz2 \
  php-igbinary \
  php${PHP_VERSION}-imap \
  php${PHP_VERSION}-intl \
  php${PHP_VERSION}-memcached \
  php${PHP_VERSION}-mysql \
  php${PHP_VERSION}-pgsql \
  php${PHP_VERSION}-sqlite \
  php${PHP_VERSION}-redis \
  php${PHP_VERSION}-soap \
  php${PHP_VERSION}-sqlite3 \
  php${PHP_VERSION}-tidy \
  php${PHP_VERSION}-common \
  php${PHP_VERSION}-xml \
  php${PHP_VERSION}-yaml \
  php${PHP_VERSION}-xdebug \
  php${PHP_VERSION}-mbstring \
  php${PHP_VERSION}-zip \
  php${PHP_VERSION}-curl \
  mcrypt unzip \
  php${PHP_VERSION}-odbc \
  php-pear \
  debconf-utils gcc build-essential unixodbc-dev nginx rsync unixodbc \
  && apt-get -qy autoremove \
  && apt-get clean \
  && rm -r /var/lib/apt/lists/*

source /etc/lsb-release
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/${DISTRIB_RELEASE}/prod.list > /etc/apt/sources.list.d/mssql-release.list

apt-get update && ACCEPT_EULA=Y apt-get install -y unixodbc-dev msodbcsql17 mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# PHP7.4 preview instructions https://github.com/microsoft/msphpsql/pull/1062/files
[[ $PHP_VERSION = "7.4" ]] && MSSQL_VERSION="-5.7.0preview" || MSSQL_VERSION=""

pecl channel-update pecl.php.net
pecl install sqlsrv${MSSQL_VERSION} pdo_sqlsrv${MSSQL_VERSION}

apt-get -y remove php${PHP_VERSION}-dev php-pear debconf-utils gcc build-essential unixodbc-dev

rsync --remove-source-files -a /nginx-tmp/ /etc/nginx
