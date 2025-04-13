#!/bin/sh
set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

echo 'Installing deps' \
  && bundle install

# Make bin/dev executable
chmod +x bin/dev

# Execute the command passed to docker run
exec "$@"