export BEEGFS_VERSION=7
export BEEGFS_KERNEL_VERSION=$(uname -r)

docker build --build-arg BEEGFS_VERSION=${BEEGFS_VERSION} \
    --build-arg BEEGFS_KERNEL_VERSION=${BEEGFS_KERNEL_VERSION} \
    -t brtknr/beegfs-client:${BEEGFS_VERSION} .

docker run --name beegfs-client -e "BEEGFS_VERSION=${BEEGFS_VERSION}" \
     -e "BEEGFS_KERNEL_VERSION=${BEEGFS_KERNEL_VERSION}" --rm --privileged \
     brtknr/beegfs-client:${BEEGFS_VERSION} modprobe beegfs
