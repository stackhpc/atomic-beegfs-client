# beegfs-client-k8s

This repository contains the essential ingredients to deploy BeeGFS client
inside a Fedora or a CentOS host. It installs BeeGFS client package on a Fedora
base image and runs the necessary step of building the BeeGFS kernel module
using the kernel version of the host.

Check which network BeeGFS is using and if RDMA is enabled:

    kubectl exec -it ds/beegfs-ds -n kube-system beegfs-net
