#! /bin/env bash
BEEGFS_MGMTD_HOST="${VAR1:-localhost}"
sed -i -e 's/^buildArgs=.*$/buildArgs=-j8 BEEGFS_OPENTK_IBVERBS=0/' /etc/beegfs/beegfs-client-autobuild.conf
sed -i -e 's/^sysMgmtdHost.*$/sysMgmtdHost = beegfs-mgmtd-host/' /etc/beegfs/beegfs-client.conf
grep -q 'beegfs-mgmtd-host$' /etc/hosts && sed -i 's/^.* beegfs-mgmtd-host$/'$BEEGFS_MGMTD_HOST' beegfs-mgmtd-host/' /etc/hosts || echo "
# BeeGFS management host
$BEEGFS_MGMTD_HOST beegfs-mgmtd-host" >> /etc/hosts
/etc/init.d/beegfs-helperd start
/etc/init.d/beegfs-client start
