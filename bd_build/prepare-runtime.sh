#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

rsync --remove-source-files -a /etc/php/version/ /etc/php/${PHP_VERSION}

# User isolation
addgroup --system services
adduser --system --no-create-home --group --disabled-login nginx
adduser --system --no-create-home --group --disabled-login php-fpm
usermod -a -G services nginx
usermod -a -G services php-fpm

curl -sS https://getcomposer.org/installer | php -- --version=1.10.16 --install-dir=/usr/local/bin/ --filename=composer

# Remove xdebug so it doesnt slow everything down
echo '' > /etc/php/${PHP_VERSION}/mods-available/*xdebug.ini
mkdir -p /etc/php/${PHP_VERSION}/mods-available/xdebug
ln -s /etc/php/${PHP_VERSION}/mods-available /p

# Symlink 99_ overrides to both CLI and FPM
ln -s /etc/php/${PHP_VERSION}/mods-available/99_* /etc/php/${PHP_VERSION}/cli/conf.d/
ln -s /etc/php/${PHP_VERSION}/mods-available/99_* /etc/php/${PHP_VERSION}/fpm/conf.d/

# Finish installation of MSSQL drivers
echo 'extension=sqlsrv.so' > /etc/php/${PHP_VERSION}/mods-available/50-sqlsrv.ini
echo 'extension=pdo_sqlsrv.so' > /etc/php/${PHP_VERSION}/mods-available/50-pdo_sqlsrv.ini
ln -s /etc/php/${PHP_VERSION}/mods-available/50-* /etc/php/${PHP_VERSION}/cli/conf.d/
ln -s /etc/php/${PHP_VERSION}/mods-available/50-* /etc/php/${PHP_VERSION}/fpm/conf.d/

# Prepare web root
mkdir -p /var/www
chmod -R 740 /var/www
chown -R www-data:www-data /var/www

# Setup composer
mkdir -p ${COMPOSER_HOME}/cache
mkdir -p ${COMPOSER_HOME}/vendor
composer global require hirak/prestissimo
chmod -R 740 ${COMPOSER_HOME}
chown -R www-data:www-data ${COMPOSER_HOME}

# Ensure permissions
chmod +x /etc/service/*/run
chmod +x /etc/my_init.d/*
chmod +x /utils/*

# Ensure nginx can write logs and php can make socket and pid file
mkdir -p /var/log/nginx
chown -R nginx:nginx /var/log/nginx
mkdir -p /run/php

# Disable auto start of nginx and php via init.d
rm -f /etc/init.d/nginx /etc/init.d/php* /etc/init/php*


# What this mean? So if 10 PHP-FPM child processes exit with SIGSEGV or SIGBUS within 1 minute
# then PHP-FPM restart automatically. This configuration also sets 10 seconds time limit for
# child processes to wait for a reaction on signals from master.
sed -r -i 's/;?emergency_restart_threshold = .*/emergency_restart_threshold = 10/g' /etc/php/${PHP_VERSION}/fpm/php-fpm.conf
sed -r -i 's/;?emergency_restart_interval = .*/emergency_restart_interval = 1m/g' /etc/php/${PHP_VERSION}/fpm/php-fpm.conf
sed -r -i 's/;?process_control_timeout = .*/process_control_timeout = 10s/g' /etc/php/${PHP_VERSION}/fpm/php-fpm.conf
# Allow PHP-FPM to log to stdout/stderr
sed -r -i 's/;?error_log = .*/error_log = \/dev\/stderr/g' /etc/php/${PHP_VERSION}/fpm/php-fpm.conf

# /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sed -r -i 's/;?catch_workers_output = .*/catch_workers_output = yes/g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sed -r -i 's/;?decorate_workers_output = .*/decorate_workers_output = no/g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sed -r -i 's/;?daemonize = .*/daemonize = no/g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

sed -r -i 's/listen = .*/listen = 127.0.0.1:9999/g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

sed -r -i 's/pm = .*/pm = static/g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sed -r -i 's/pm.max_children = .*/pm.max_children = 10/g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sed -r -i 's/;?pm.status_path = .*/pm.status_path = \/fpm\/status/g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sed -r -i 's/;?ping.path = .*/ping.path = \/fpm\/ping/g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf


# Prep crontab
echo '* * * * * www-data php /var/www/html/artisan schedule:run' > /etc/cron.d/artisan
sed -i -e '$a\\' /etc/cron.d/artisan

# Set up the shell
echo "export PS1='🐳  \[\033[1;36m\]\h \[\033[1;34m\]\W\[\033[0;35m\] \[\033[1;36m\]# \[\033[0m\]'" >> /root/.bashrc
echo "alias ll='ls -lh'" >> /root/.bashrc
echo "alias art='php artisan'" >> /root/.bashrc
echo "alias phpunit='vendor/bin/phpunit'" >> /root/.bashrc
echo "alias p='phpunit'" >> /root/.bashrc
echo "alias pf='phpunit --filter'" >> /root/.bashrc
echo "alias pst='phpunit --stop-on-failure'" >> /root/.bashrc
echo "alias paratest='vendor/bin/paratest --colors'" >> /root/.bashrc
echo "alias c='composer'" >> /root/.bashrc
