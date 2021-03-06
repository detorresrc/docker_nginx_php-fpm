#!/bin/bash
# Set Permission
chown -Rf www-data:www-data /var/www/*

source /usr/local/bin/envvars
while true
do
    /usr/local/bin/apachectl -DFOREGROUND
    sleep 1
done