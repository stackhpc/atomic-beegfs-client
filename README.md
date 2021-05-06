# beegfs-client-k8s

This repository contains the essential ingredients to deploy BeeGFS client
inside a Fedora or a CentOS host. It installs BeeGFS client package on a Fedora
base image and runs the necessary step of building the BeeGFS kernel module
using the kernel version of the host.

To install the helm chart:

    make install

You will need to modify `chart/values.yaml` to enable Infiniband verbs as it is
disabled by default.

Check which network BeeGFS is using and if RDMA is enabled:

    kubectl exec -it ds/beegfs-client -n kube-system beegfs-net

NOTE: The latest version of BeeGFS client container image built by this repo is
7.1.4 after applying a patch contained under `fedora/bin/beegfs-7.1.4.patch`.
However, the latest Kernel version that this patched version of BeeGFS will
build on is `5.6.14-300.fc32.x86_64` which is the underlying Kernel version in
`fedora-coreos-32.20200601.3.0-openstack.x86_64`.
