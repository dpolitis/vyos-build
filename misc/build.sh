#!/bin/bash

sudo git clone -b sagitta --single-branch https://github.com/vyos/vyos-build .
sudo git checkout $(git describe --tags)
sudo git checkout -b $(git describe --tags)

sudo make clean
sudo make purge

major=$(grep loop /proc/devices | cut -c3)
for index in {0..5}
do
  sudo -E mknod /dev/loop${index} b $major ${index}
done

sudo ./build-vyos-image iso \
--architecture amd64 \
--build-by "civisd@gmail.com" \
--build-type release \
--version ${1}

sudo cp build/live-image-amd64.hybrid.iso vyos-${1}-amd64.iso

sudo -E make qemu
sudo -E make vmware
sudo cp build/vyos_vmware_image-signed.ova vyos-${1}-amd64.ova

sudo make clean
sudo make purge

sudo chown vyos_bld:vyos_bld vyos-${1}-amd64.ova vyos-${1}-amd64.iso

