#! /bin/env sh

for i in storage-nvmerc storage-ssdrc openhpcrc; do
  source ./$i
  make rmall
done
