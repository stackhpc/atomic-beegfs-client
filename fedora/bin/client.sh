#! /bin/bash

set -eux

cat << EOF >> /etc/hosts
$BEEGFS_CLIENT_IP	$BEEGFS_CLIENT_NAME
EOF

until ping -c 1 -W 1 $BEEGFS_CLIENT_NAME; do
    echo "Waiting for $BEEGFS_CLIENT_NAME ($BEEGFS_CLIENT_IP) - network interface might be down..."
    sleep 1
done

BEEGFS_BUILD_ARGS="${BEEGFS_BUILD_ARGS:--j8}"

sed -i -e "s/^buildArgs=.*$/buildArgs=$BEEGFS_BUILD_ARGS/" /etc/beegfs/beegfs-client-autobuild.conf
sed -i -e "s/^sysMgmtdHost.*$/sysMgmtdHost = $BEEGFS_CLIENT_IP/" /etc/beegfs/beegfs-client.conf

echo "Configure helper port"
BEEGFS_HELPER_PORT=${BEEGFS_HELPER_PORT:-8006}
sed -i -e "s/^connHelperdPortTCP.*$/connHelperdPortTCP = ${BEEGFS_HELPER_PORT}/" /etc/beegfs/beegfs-client.conf

echo "Configure client port"
sed -i -e "s/^connClientPortUDP.*$/connClientPortUDP = ${BEEGFS_CLIENT_PORT}/" /etc/beegfs/beegfs-client.conf

# Install kernel header
#for i in core devel modules; do
#  koji download-build --rpm --arch=x86_64 kernel-$i-`uname -r`
#  dnf install -y kernel-$i-`uname -r`.rpm
#  rm kernel-$i-`uname -r`.rpm
#done
#dnf clean all

echo "Starting BeeGFS..."
/etc/init.d/beegfs-client start

_term() { 
  echo "Caught SIGTERM signal!" 
  umount /mnt/beegfs
  /etc/init.d/beegfs-client stop
  kill -TERM "$child" 2>/dev/null
  echo "BeeGFS has stopped..."
  exit 0
}

trap _term SIGTERM SIGINT

echo "Entering daemon mode... (press Ctrl+C to exit.)" && sleep infinity &

child=$! 
wait "$child"
