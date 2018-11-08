#! /bin/env bash

export BEEGFS_VERSION=7_1
export BEEGFS_KERNEL_VERSION=$(uname -r)
export BEEGFS_MGMTD_HOST=10.60.253.20
export BEEGFS_MOUNT_PATH=/mnt/beegfs
echo $BEEGFS_VERSION

docker build --build-arg BEEGFS_VERSION=${BEEGFS_VERSION} \
    --build-arg BEEGFS_KERNEL_VERSION=${BEEGFS_KERNEL_VERSION} \
    -t brtknr/beegfs-client:${BEEGFS_VERSION} . && \
    docker push brtknr/beegfs-client:${BEEGFS_VERSION} && \
    mkdir -p $BEEGFS_MOUNT_PATH
    docker run --name beegfs-client -d \
        -e "BEEGFS_MGMTD_HOST=${BEEGFS_MGMTD_HOST}" --rm --privileged \
        --network=host --mount type=bind,src=${BEEGFS_MOUNT_PATH},target=${BEEGFS_MOUNT_PATH},bind-propagation=shared \
        brtknr/beegfs-client:${BEEGFS_VERSION}
