#!/bin/sh

# ROM化を無効にするスクリプト

if [ -e /mnt/boot-ro/config.txt ]; then
    sudo mount -o remount,rw /dev/mmcblk0p1
    sudo grep -v initramfs /mnt/boot-ro/config.txt >/tmp/config.txt
    sudo cp /tmp/config.txt /mnt/boot-ro/config.txt
    sudo reboot
else
    echo "Already write enabled"
fi