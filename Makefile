BEEGFS_VERSION ?= 7_1
BEEGFS_KERNEL_VERSION ?= $(uname -r)
BEEGFS_MGMTD_HOST ?= 10.60.253.20
BEEGFS_MOUNT_PATH ?= /mnt/beegfs/
BEEGFS_CLIENT_PREFIX ?= fedora@10.60.253
BEEGFS_CLIENT_SUFFIX ?= 14 30 36 18 32 32 35

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
      - image: docker.io/brtknr/beegfs-client:${BEEGFS_VERSION}
        imagePullPolicy: Always
        name: beegfs-test
        env:
        - name: BEEGFS_MGMTD_HOST
          value: ${BEEGFS_MGMTD_HOST}
        volumeMounts:
        - mountPath: ${BEEGFS_MOUNT_PATH}
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
    image: docker.io/brtknr/beegfs-client:${BEEGFS_VERSION}
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
        target: ${BEEGFS_MOUNT_PATH}

endef

export BEEGFS_MANIFEST_K8S
export BEEGFS_MANIFEST_SWARM

docker: build push

build:
	sudo docker build --build-arg BEEGFS_VERSION=${BEEGFS_VERSION} \
	--build-arg BEEGFS_KERNEL_VERSION=${BEEGFS_KERNEL_VERSION} \
	-t brtknr/beegfs-client:${BEEGFS_VERSION} .

push:
	sudo docker push brtknr/beegfs-client:${BEEGFS_VERSION}

dir:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo mkdir -p ${BEEGFS_MOUNT_PATH}; done

k8s:
	mkdir -p manifest
	echo "$${BEEGFS_MANIFEST_K8S}" > manifest/k8s.yml
	kubectl apply -f manifest/k8s.yml

swarm:
	for i in ${BEEGFS_CLIENT_SUFFIX}; do ssh ${BEEGFS_CLIENT_PREFIX}.$${i} sudo docker run -it --privileged --mount source=/mnt/beegfs/,target=/mnt/beegfs,type=bind,bind-propagation=rshared -e BEEGFS_MGMTD_HOST=10.60.253.20 --net=host docker.io/brtknr/beegfs-client:7_1; done
