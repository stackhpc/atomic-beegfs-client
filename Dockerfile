FROM fedora
MAINTAINER "Bharat Kunwar" <bharat@stackhpc.com>

ARG BEEGFS_VERSION
ARG BEEGFS_KERNEL_VERSION

WORKDIR /tmp

RUN curl -L -o /etc/yum.repos.d/beegfs-rhel7.repo \
    http://www.beegfs.com/release/beegfs_${BEEGFS_VERSION}/dists/beegfs-rhel7.repo && \
    dnf update -y && dnf install -y \
        beegfs-client beegfs-helperd beegfs-utils \
        libmnl-devel elfutils-libelf-devel findutils binutils boost-atomic boost-chrono \
        boost-date-time boost-system boost-thread cpp dyninst efivar-libs gc \
        gcc glibc-devel glibc-headers guile koji isl libatomic_ops libdwarf libmpc \
        libpkgconf libtool-ltdl libxcrypt-devel make mokutil pkgconf pkgconf-m4 \
        pkgconf-pkg-config unzip zip /usr/bin/pkg-config xz -y && \
        koji download-build --rpm --arch=x86_64 kernel-core-${BEEGFS_KERNEL_VERSION} && \
        koji download-build --rpm --arch=x86_64 kernel-devel-${BEEGFS_KERNEL_VERSION} && \
        koji download-build --rpm --arch=x86_64 kernel-modules-${BEEGFS_KERNEL_VERSION} && \
        dnf install -y kernel-core-${BEEGFS_KERNEL_VERSION}.rpm \
        kernel-devel-${BEEGFS_KERNEL_VERSION}.rpm \
        kernel-modules-${BEEGFS_KERNEL_VERSION}.rpm && \
        dnf clean all && rm -f /tmp/*.rpm

COPY setup.sh /tmp/setup.sh
RUN /tmp/setup.sh

COPY run.sh /tmp/run.sh
ENTRYPOINT /tmp/run.sh
