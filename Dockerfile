FROM alpine:3.16

# Install S6.
RUN set -e; \
    mkdir /tmp/root; \
    wget https://github.com/just-containers/s6-overlay/releases/download/v3.1.0.1/s6-overlay-noarch.tar.xz -P /tmp; \
    wget https://github.com/just-containers/s6-overlay/releases/download/v3.1.0.1/s6-overlay-$(uname -m).tar.xz -P /tmp; \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
    tar -C / -Jxpf /tmp/s6-overlay-$(uname -m).tar.xz; \
    rm -f /tmp/*.tar.xz

# Install required packages.
RUN apk add --no-cache nfs-utils rpcbind
RUN rm -f /etc/exports

ENTRYPOINT ["/init"]

RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/rpc.mountd \
          /etc/s6-overlay/s6-rc.d/user/contents.d/rpc.nfsd \
          /etc/s6-overlay/s6-rc.d/user/contents.d/exportfs \
          /etc/s6-overlay/s6-rc.d/user/contents.d/rpcbind

COPY services/rpc.mountd /etc/s6-overlay/s6-rc.d/rpc.mountd
COPY services/rpc.nfsd /etc/s6-overlay/s6-rc.d/rpc.nfsd
COPY services/rpcbind /etc/s6-overlay/s6-rc.d/rpcbind
COPY services/exportfs /etc/s6-overlay/s6-rc.d/exportfs

ENV AUTO_MOUNT=true \
    AUTO_MOUNT_BASE=/mnt \
    AUTO_MOUNT_CIDR="*" \
    AUTO_MOUNT_READ_ONLY=false \
    AUTO_MOUNT_SYNC=false

ENV NFS_MOUNT_ROOT="/mnt" \
    NFS_INSECURE=true