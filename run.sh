#! /bin/env bash
BEEGFS_MGMTD_HOST="${BEEGFS_MGMTD_HOST:-localhost}"
echo "
# BeeGFS management host
$BEEGFS_MGMTD_HOST beegfs-mgmtd-host" >> /etc/hosts
while ! ping -c 1 -W 1 $BEEGFS_MGMTD_HOST; do
    echo "Waiting for $BEEGFS_MGMTD_HOST - network interface might be down..."
    sleep 1
done
/etc/init.d/beegfs-helperd start && sleep 5 && /etc/init.d/beegfs-client start
while 1; do
    echo "Entering daemon mode..."
    sleep 1
done
