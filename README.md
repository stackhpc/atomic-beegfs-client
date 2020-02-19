# atomic-beegfs-client

This repository contains the essential ingredients to deploy BeeGFS client
inside a Fedora Atomic (FA) host. It installs BeeGFS client package on a Fedora
base image and runs the necessary step of building the BeeGFS kernel module
using the kernel version of the host. Docker image needs to be built inside the
host so that the kernel version of the host matches that of the kernel module
when invoking `build.sh`.

Check which network BeeGFS is using and if RDMA is enabled:

    kubectl exec -it ds/beegfs-ds -n kube-system beegfs-net
