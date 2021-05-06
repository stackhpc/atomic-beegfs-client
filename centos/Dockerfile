FROM centos:7
MAINTAINER "Bharat Kunwar" <bharat@stackhpc.com>

ARG BEEGFS_VERSION=7.1.4

RUN curl -L -o /etc/yum.repos.d/beegfs-rhel7.repo \
    https://www.beegfs.io/release/beegfs_${BEEGFS_VERSION}/dists/beegfs-rhel7.repo && \
    yum install -y beegfs-client beegfs-helperd beegfs-utils

COPY bin/* /

ENTRYPOINT /client.sh
