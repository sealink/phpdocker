#!/bin/bash


# Pull down code form git for our site!
if [ ! -z "$GIT_REPO" ]; then
  rm /app*
  if [ ! -z "$GIT_BRANCH" ]; then
    git clone -b $GIT_BRANCH $GIT_REPO /app
  else
    git clone $GIT_REPO /app
  fi
  chown -Rf nginx.nginx /app*
fi

# Tweak nginx to match the workers to cpu's

procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $procs/" /etc/nginx/nginx.conf

# Very dirty hack to replace variables in code with ENVIRONMENT values
if [ ! -z "$ENV_REPLACE_FOLDER" ]; then
   folder=$ENV_REPLACE_FOLDER
else
   folder=/app/public
fi

echo "Replacing all env vars in ${folder}"

for i in $(env)
do
  variable=$(echo "$i" | cut -d'=' -f1)
  value=$(echo "$i" | cut -d'=' -f2)
  if [[ "$variable" != '%s' ]] ; then
    replace='\$\$_'${variable}'_\$\$'
    find $folder -type f -exec sed -i -e 's@'${replace}'@'${value}'@g' {} \; ; fi
  done

# Start supervisord and services
exec /usr/local/bin/supervisord -n
