#! /bin/env bash
BEEGFS_MGMTD_HOST="${BEEGFS_MGMTD_HOST:-localhost}"
echo "
# BeeGFS management host
$BEEGFS_MGMTD_HOST beegfs-mgmtd-host" >> /etc/hosts
/etc/init.d/beegfs-helperd start && /etc/init.d/beegfs-client start
