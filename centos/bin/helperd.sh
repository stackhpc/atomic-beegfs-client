#! /bin/bash

set -eux

echo "Starting BeeGFS helper..."
sed -i -e "s/^if isSystemdPresent/if false/" /etc/init.d/beegfs-helperd
/etc/init.d/beegfs-helperd start

_term() { 
  echo "Caught SIGTERM signal!" 
  /etc/init.d/beegfs-helperd stop
  kill -TERM "$child" 2>/dev/null
  echo "BeeGFS helper has stopped..."
  exit 0
}

trap _term SIGTERM SIGINT

echo "Entering daemon mode... (press Ctrl+C to exit.)" && sleep infinity &

child=$! 
wait "$child"
