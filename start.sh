#!/bin/bash

# Disable Strict Host checking for non interactive git clones

echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

# Pull down code form git for our site!
if [ ! -z "$GIT_REPO" ]; then
  rm /usr/cms*
  if [ ! -z "$GIT_BRANCH" ]; then
    git clone -b $GIT_BRANCH $GIT_REPO /usr/cms
  else
    git clone $GIT_REPO /usr/cms
  fi
  chown -Rf nginx.nginx /usr/cms*
fi

# Tweak nginx to match the workers to cpu's

procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $procs/" /etc/nginx/nginx.conf

# Start supervisord and services
/usr/local/bin/supervisord -n
