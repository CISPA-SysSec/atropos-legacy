#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
sudo modprobe -r kvm-intel
sudo modprobe -r kvm
sudo modprobe  kvm enable_vmware_backdoor=y
sudo modprobe  kvm-intel
cat /sys/module/kvm/parameters/enable_vmware_backdoor
sudo chmod 777 /dev/kvm 
export SHAREDIR=$(realpath $SCRIPT_DIR/webapp_share/)
export WORKDIR=/dev/shm/workdir_$(basename $SHAREDIR)
