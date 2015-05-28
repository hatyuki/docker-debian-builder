#!/bin/bash -eu

if [ ${1:-''} = 'build' ]; then
    shift
    release=${1:-'stable'}
    mirror=http://ftp.jp.debian.org/debian
    workdir=rootfs
    LANG=C

    if [ -d $workdir ]; then
        rm -rf $workdir
    fi

    if [ ! -d image ]; then
        mkdir image
    else
        rm -rf image/{rootfs.tar.xz,Dockerfile}
    fi

    # Clone repository
    git clone --depth 1 https://github.com/docker/docker.git

    # Create base image
    if [ $release = 'wheezy' -o $release = 'oldstable' ]; then
        iproute=iproute
    else
        iproute=iproute2
    fi

    ./docker/contrib/mkimage.sh -d . debootstrap --verbose --variant=minbase --include=$iproute,locales --arch=amd64 $release $mirror

    # Extract base image
    mkdir $workdir
    tar --numeric-owner -xf rootfs.tar.xz -C $workdir

    # Set locales
    chroot $workdir sed -i 's/^#\s*\(ja_JP.UTF-8.*\)$/\1/' /etc/locale.gen
    chroot $workdir dpkg-reconfigure --frontend noninteractive locales

    # Set timezone
    echo Asia/Tokyo > $workdir/etc/timezone
    chroot $workdir dpkg-reconfigure --frontend noninteractive tzdata

    # Cleanup container
    rm -rf $workdir/usr/share/doc/*
    rm -rf $workdir/usr/share/man/*
    find $workdir/var/cache -type f -exec rm -f {} \;
    find $workdir/var/lib/apt -type f -exec rm -f {} \;
    find $workdir/var/log -type f | while read f; do :> $f; done;
    rm -rf $workdir/{dev,proc}
    mkdir -p $workdir/{dev,proc}

    # create docker image
    pushd $workdir
    tar --numeric-owner -caf ../image/rootfs.tar.xz .
    popd

    mv Dockerfile image/
else
    exec $@
fi
