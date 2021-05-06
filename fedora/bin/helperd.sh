#! /bin/bash

set -eux

echo "Starting BeeGFS helper..."
sed -i -e "s/^if isSystemdPresent/if false/" /etc/init.d/beegfs-helperd
sed -i -e "s/^logStdFile.*$/logStdFile =/" /etc/beegfs/beegfs-helperd.conf
sed -i -e "s/^runDaemonized.*$/runDaemonized = false/" /etc/beegfs/beegfs-helperd.conf

/etc/init.d/beegfs-helperd start
