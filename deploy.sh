BEEGFS_MGMTD_HOST ?= 10.60.253.20 # 20=nvme 50=ssd #40=openhpc
BEEGFS_HELPER_PORT ?= 8024
BEEGFS_MOUNT_PATH ?= /mnt/storage-nvme
make rmall
make dir
make runall
BEEGFS_MGMTD_HOST ?= 10.60.253.50 # 20=nvme 50=ssd #40=openhpc
BEEGFS_HELPER_PORT ?= 8054
BEEGFS_MOUNT_PATH ?= /mnt/storage-ssd
make rmall
make dir
make runall
BEEGFS_MGMTD_HOST ?= 10.60.253.40 # 20=nvme 50=ssd #40=openhpc
BEEGFS_HELPER_PORT ?= 8044
BEEGFS_MOUNT_PATH ?= /mnt/openhpc
make rmall
make dir
make runall
