#! /bin/env sh

set -xe

BEEGFS_MGMTD_HOST="${BEEGFS_MGMTD_HOST:-localhost}"

cat << EOF >> /etc/hosts
# BeeGFS management host
$BEEGFS_MGMTD_HOST beegfs-mgmtd-host
EOF

while ! ping -c 1 -W 1 $BEEGFS_MGMTD_HOST; do
    echo "Waiting for $BEEGFS_MGMTD_HOST - network interface might be down..."
    sleep 1
done

echo "Configure helper port"
BEEGFS_HELPER_PORT="${BEEGFS_HELPER_PORT:-8006}"
sed -i -e 's/^connHelperdPortTCP.*$/connHelperdPortTCP = '${BEEGFS_HELPER_PORT}'/' /etc/beegfs/beegfs-client.conf
sed -i -e 's/^connHelperdPortTCP.*$/connHelperdPortTCP = '${BEEGFS_HELPER_PORT}'/' /etc/beegfs/beegfs-helperd.conf

echo "Configure client port"
BEEGFS_CLIENT_PORT="${BEEGFS_CLIENT_PORT:-8004}"
sed -i -e 's/^connClientPortUDP.*$/connClientPortUDP = '${BEEGFS_CLIENT_PORT}'/' /etc/beegfs/beegfs-client.conf

echo "Starting BeeGFS..."
/etc/init.d/beegfs-helperd start && /etc/init.d/beegfs-client start

_term() { 
  echo "Caught SIGTERM signal!" 
  umount /mnt/beegfs
  /etc/init.d/beegfs-client stop && /etc/init.d/beegfs-helperd stop
  kill -TERM "$child" 2>/dev/null
  echo "BeeGFS has stopped..."
  exit 0
}

trap _term SIGTERM SIGINT

echo "Entering daemon mode... (press Ctrl+C to exit.)" && sleep infinity &

child=$! 
wait "$child"

