#! /bin/env bash
sed -i -e 's/^buildArgs=.*$/buildArgs=-j8 BEEGFS_OPENTK_IBVERBS=1/' /etc/beegfs/beegfs-client-autobuild.conf
sed -i -e 's/^sysMgmtdHost.*$/sysMgmtdHost = beegfs-mgmtd-host/' /etc/beegfs/beegfs-client.conf
/etc/init.d/beegfs-client rebuild
