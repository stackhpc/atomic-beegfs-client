export BEEGFS_VERSION=7
export BEEGFS_KERNEL_VERSION=$(uname -r)

sudo docker build --build-arg BEEGFS_VERSION=${BEEGFS_VERSION} \
    --build-arg BEEGFS_KERNEL_VERSION=${BEEGFS_KERNEL_VERSION} \
    -t brtknr/beegfs-client:${BEEGFS_VERSION} git://github.com/brtknr/atomic-beegfs-client

sudo docker run --name beegfs-client -e "BEEGFS_VERSION=${BEEGFS_VERSION}" \
     -e "BEEGFS_KERNEL_VERSION=${BEEGFS_KERNEL_VERSION}" --rm --privileged \
     beegfs-client:${BEEGFS_VERSION} modprobe beegfs

sudo docker run --name beegfs-client -e "BEEGFS_VERSION=${BEEGFS_VERSION}" \
     -e "BEEGFS_KERNEL_VERSION=${BEEGFS_KERNEL_VERSION}" --rm --privileged \
     beegfs-client:${BEEGFS_VERSION} \
     insmod /usr/lib/modules/${BEEGFS_KERNEL_VERSION}/extra/beegfs.ko
