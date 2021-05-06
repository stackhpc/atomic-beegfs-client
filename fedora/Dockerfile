FROM fedora:32
MAINTAINER "Bharat Kunwar" <bharat@stackhpc.com>

ARG BEEGFS_VERSION=7.1.4
ARG KERNEL_VERSION=5.6.14-300.fc32.x86_64

RUN curl -L -o /etc/yum.repos.d/beegfs-rhel7.repo \
      https://www.beegfs.io/release/beegfs_${BEEGFS_VERSION}/dists/beegfs-rhel7.repo && \
    dnf install -y \
        beegfs-client beegfs-helperd beegfs-utils libbeegfs-ib iputils patchutils diffutils \
        libmnl-devel elfutils-libelf-devel findutils binutils boost-atomic boost-chrono \
        boost-date-time boost-system boost-thread cpp dyninst efivar-libs gc \
        gcc glibc-devel glibc-headers guile koji isl libatomic_ops libdwarf libmpc \
        libpkgconf libtool-ltdl libxcrypt-devel make mokutil pkgconf pkgconf-m4 \
        pkgconf-pkg-config unzip zip /usr/bin/pkg-config xz -y && \
      koji download-build --rpm --arch=x86_64 kernel-core-${KERNEL_VERSION} && \
      koji download-build --rpm --arch=x86_64 kernel-devel-${KERNEL_VERSION} && \
      koji download-build --rpm --arch=x86_64 kernel-modules-${KERNEL_VERSION} && \
      dnf install -y kernel-core-${KERNEL_VERSION}.rpm \
        kernel-devel-${KERNEL_VERSION}.rpm \
        kernel-modules-${KERNEL_VERSION}.rpm && \
      dnf clean all && rm -f /tmp/*

COPY bin/* /

RUN patch -N -p0 -d /opt/beegfs/src/client < /beegfs-7.1.4.patch

ENTRYPOINT /client.sh
