BEEGFS_VERSION ?= 7_1
BEEGFS_KERNEL_VERSION ?= $(shell uname -r)
BEEGFS_MGMTD_HOST ?= 10.60.253.20# 20=nvme 50=ssd #40=openhpc
BEEGFS_HELPER_PORT ?= 8026# 20=nvme 50=ssd #40=openhpc
BEEGFS_CLIENT_PORT ?= 8024# 20=nvme 50=ssd #40=openhpc
BEEGFS_MOUNT_PATH ?= /mnt/storage-nvme
BEEGFS_CONTAINER_REPO ?= docker.io/stackhpc
BEEGFS_CLIENT_PREFIX ?= fedora@10.60.253
BEEGFS_CLIENT_SUFFIX ?= 13 61 19 56
BEEGFS_CLIENT_SUFFIX ?= 43 63 39 53 31 34 59

define BEEGFS_MANIFEST_K8S
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: beegfs-ds
    tier: monitor
  name: beegfs-ds
  namespace: default
spec:
  selector:
    matchLabels:
      name: beegfs-ds
  template:
    metadata:
      labels:
        name: beegfs-ds
      name: beegfs-pod
    spec:
      containers:
      - image: ${BEEGFS_CONTAINER_REPO}/beegfs-client:${BEEGFS_VERSION}-${BEEGFS_KERNEL_VERSION}
        imagePullPolicy: Always
        name: beegfs-test
        env:
        - name: BEEGFS_MGMTD_HOST
          value: ${BEEGFS_MGMTD_HOST}
        volumeMounts:
        - mountPath: /mnt/beegfs
          name: beegfs-vol
          mountPropagation: Bidirectional
        securityContext:
          privileged: true
      hostNetwork: true
      volumes:
      - name: beegfs-vol
        hostPath:
          path: ${BEEGFS_MOUNT_PATH}
endef

define BEEGFS_MANIFEST_SWARM
---
version: "3.6"

networks:
  hostnet:
    external: true
    name: host

services:
  beegfs-ds:
    privileged: true
    image: ${BEEGFS_CONTAINER_REPO}/beegfs-client:${BEEGFS_VERSION}-${BEEGFS_KERNEL_VERSION}
    networks:
      hostnet: {}
    deploy:
      mode: global
    environment:
      - "BEEGFS_MGMTD_HOST=${BEEGFS_MGMTD_HOST}"
    volumes:
      - type: bind
        bind:
          propagation: shared
        source: ${BEEGFS_MOUNT_PATH}
        target: /mnt/beegfs

endef

export BEEGFS_MANIFEST_K8S
export BEEGFS_MANIFEST_SWARM

image: build push

echo:
	echo ${BEEGFS_KERNEL_VERSION}
	echo ${BEEGFS_VERSION}

build:
	sudo docker build --build-arg BEEGFS_VERSION=${BEEGFS_VERSION} \
	--build-arg BEEGFS_KERNEL_VERSION=${BEEGFS_KERNEL_VERSION} \
	-t ${BEEGFS_CONTAINER_REPO}/beegfs-client:${BEEGFS_VERSION}-${BEEGFS_KERNEL_VERSION} .

push:
	sudo docker push ${BEEGFS_CONTAINER_REPO}/beegfs-client:${BEEGFS_VERSION}-${BEEGFS_KERNEL_VERSION}

dir:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo mkdir -p ${BEEGFS_MOUNT_PATH}; sudo rm -rf ${BEEGFS_MOUNT_PATH}/*; done

rmmod:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do (ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo rmmod mlx5_ib &); done

modprobe:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do (ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo modprobe mlx5_ib &); done

k8s:
	mkdir -p manifest
	echo "$${BEEGFS_MANIFEST_K8S}" > manifest/k8s.yml
	kubectl apply -f manifest/k8s.yml

docker: rmall dir pullall runall 

pullall:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do (ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo docker pull ${BEEGFS_CONTAINER_REPO}/beegfs-client:${BEEGFS_VERSION}-${BEEGFS_KERNEL_VERSION} &) ; done

runall:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do (ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo docker run -d --name beegfs-client-${BEEGFS_MGMTD_HOST} --restart=always --privileged --mount source=${BEEGFS_MOUNT_PATH},target=/mnt/beegfs,type=bind,bind-propagation=rshared -e BEEGFS_MGMTD_HOST=${BEEGFS_MGMTD_HOST} -e BEEGFS_HELPER_PORT=${BEEGFS_HELPER_PORT} -e BEEGFS_CLIENT_PORT=${BEEGFS_CLIENT_PORT} --net=host ${BEEGFS_CONTAINER_REPO}/beegfs-client:${BEEGFS_VERSION}-${BEEGFS_KERNEL_VERSION} &); done

rmall:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do (ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo docker rm -f beegfs-client-${BEEGFS_MGMTD_HOST} &); done
