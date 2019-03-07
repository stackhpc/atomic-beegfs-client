#! /bin/env sh

for i in storage-nvme-rc storage-ssd-rc openhpc-rc; do
  source ./$i
  make rmall
done
