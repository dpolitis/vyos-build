#!/bin/bash
./configure --architecture amd64 \
--build-by "civisd@gmail.com" \
--build-type release --version ${1}

sudo make iso
sudo cp build/vyos-${1}-amd64.iso .

sudo -E make vmware
sudo cp build/vyos_vmware_image-signed.ova vyos-${1}-amd64.ova

sudo make clean
sudo make purge

sudo chown vyos_bld:vyos_bld vyos-${1}-amd64.ova vyos-${1}-amd64.iso
