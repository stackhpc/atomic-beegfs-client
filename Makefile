IMAGE ?= fedora
KERNEL_VERSION ?= 5.6.14-300.fc32.x86_64 #5.7.12-200.fc32.x86_64 #5.8.15-201.fc32.x86_64 #5.6.14-300.fc32.x86_64
BEEGFS_VERSION ?= 7.1.4
CONTAINER_IMAGE ?= ghcr.io/stackhpc/beegfs-client
CONTAINER_TAG ?= ${BEEGFS_VERSION}-${KERNEL_VERSION}

BEEGFS_CLIENT_SUFFIX ?= 43 63 39 53 31 34 59
BEEGFS_MGMTD_HOST ?= 10.60.253.20# 20=nvme 50=ssd #40=openhpc
BEEGFS_HELPER_PORT ?= 8026# 20=nvme 50=ssd #40=openhpc
BEEGFS_CLIENT_PORT ?= 8024# 20=nvme 50=ssd #40=openhpc
BEEGFS_MOUNT_PATH ?= /mnt/storage-nvme
BEEGFS_CLIENT_PREFIX ?= fedora@10.60.253
BEEGFS_CLIENT_SUFFIX ?= 13 61 19 56

echo:
	echo ${KERNEL_VERSION}
	echo ${BEEGFS_VERSION}

build:
	docker build ${IMAGE} \
	--build-arg BEEGFS_VERSION=${BEEGFS_VERSION} \
	--build-arg KERNEL_VERSION=${KERNEL_VERSION} \
	-t ${CONTAINER_IMAGE}:${CONTAINER_TAG}

login:
	echo "Username: $(DOCKER_USERNAME)"
	echo "Password: $(DOCKER_PASSWORD)"
	if [ "$(DOCKER_USERNAME)" != "" ]; then \
		echo "$(DOCKER_PASSWORD)" | docker login --username="$(DOCKER_USERNAME)" --password-stdin $(CONTAINER_IMAGE):$(CONTAINER_TAG); \
	fi; \

push: build login
	docker push ${CONTAINER_IMAGE}:${CONTAINER_TAG}

dir:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo mkdir -p ${BEEGFS_MOUNT_PATH}; sudo rm -rf ${BEEGFS_MOUNT_PATH}/*; done

rmmod:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do (ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo rmmod mlx5_ib &); done

modprobe:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do (ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo modprobe mlx5_ib &); done

install:
	helm upgrade --install beegfs-client --set image.tag=${CONTAINER_TAG} -n kube-system chart/

docker: rmall dir pullall runall 

pullall:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do (ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo docker pull ${CONTAINER_IMAGE}:${CONTAINER_TAG} &) ; done

runall:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do (ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo docker run -d --name beegfs-client-${BEEGFS_MGMTD_HOST} --restart=always --privileged --mount source=${BEEGFS_MOUNT_PATH},target=/mnt/beegfs,type=bind,bind-propagation=rshared -e BEEGFS_MGMTD_HOST=${BEEGFS_MGMTD_HOST} -e BEEGFS_HELPER_PORT=${BEEGFS_HELPER_PORT} -e BEEGFS_CLIENT_PORT=${BEEGFS_CLIENT_PORT} --net=host ${CONTAINER_IMAGE}/beegfs-client:${CONTAINER_TAG} &); done

rmall:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do (ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo docker rm -f beegfs-client-${BEEGFS_MGMTD_HOST} &); done
