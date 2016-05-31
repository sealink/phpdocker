#!/bin/bash

# Tweak nginx to match the workers to cpu's
procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $procs/" /etc/nginx/nginx.conf

# Again set the right permissions (needed when mounting from a volume)
chown -Rf nginx:nginx /app

# Start supervisord and services
exec /usr/local/bin/supervisord -n
