BEEGFS_VERSION ?= 7_1
BEEGFS_KERNEL_VERSION ?= $(uname -r)
BEEGFS_MGMTD_HOST ?= 10.60.253.20
BEEGFS_MOUNT_PATH ?= /mnt/beegfs/

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

export BEEGFS_MANIFEST_K8S

docker: build push

build:
	sudo docker build --build-arg BEEGFS_VERSION=${BEEGFS_VERSION} \
	--build-arg BEEGFS_KERNEL_VERSION=${BEEGFS_KERNEL_VERSION} \
	-t brtknr/beegfs-client:${BEEGFS_VERSION} .

push:
	sudo docker push brtknr/beegfs-client:${BEEGFS_VERSION}

k8s: manifest_k8s apply_k8s

manifest_k8s:
	mkdir -p manifest
	echo "$${BEEGFS_MANIFEST_K8S}" > manifest/k8s.yml &

apply_k8s:
	kubectl apply -f manifest/k8s.yml
