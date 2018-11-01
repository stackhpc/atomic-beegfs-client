#! /bin/env sh
BEEGFS_MGMTD_HOST="${BEEGFS_MGMTD_HOST:-localhost}"
echo "
# BeeGFS management host
$BEEGFS_MGMTD_HOST beegfs-mgmtd-host" >> /etc/hosts
while ! ping -c 1 -W 1 $BEEGFS_MGMTD_HOST; do
    echo "Waiting for $BEEGFS_MGMTD_HOST - network interface might be down..."
    sleep 1
done

/etc/init.d/beegfs-helperd start && /etc/init.d/beegfs-client start
echo "Entering daemon mode... (press Ctrl+C)" && sleep infinity
umount /mnt/beegfs && /etc/init.d/beegfs-client stop /etc/init.d/beegfs-helperd stop
echo "Beegfs has stopped... (press Ctrl+C)" && sleep infinity
