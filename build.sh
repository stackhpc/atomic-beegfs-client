#! /bin/env bash

export BEEGFS_VERSION=7
export BEEGFS_KERNEL_VERSION=$(uname -r)
export BEEGFS_MGMTD_HOST=10.60.253.20

docker build --build-arg BEEGFS_VERSION=${BEEGFS_VERSION} \
    --build-arg BEEGFS_KERNEL_VERSION=${BEEGFS_KERNEL_VERSION} \
    -t brtknr/beegfs-client:${BEEGFS_VERSION} . && \
    docker push brtknr/beegfs-client:${BEEGFS_VERSION} && \
    docker run --name beegfs-client -d \
        -e "BEEGFS_MGMTD_HOST=${BEEGFS_MGMTD_HOST}" --rm --privileged \
        --network=host --mount type=bind,src=/mnt/beegfs,target=/mnt/beegfs,bind-propagation=shared \
        brtknr/beegfs-client:${BEEGFS_VERSION}
