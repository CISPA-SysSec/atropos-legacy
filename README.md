# About

This is the code repository for the paper titled "Atropos: Effective Fuzzing of Web Applications for Server-Side Vulnerabilities" and it contains the code for our coverage-guided web application fuzzer as well as our evaluation tooling. Note that this is an academic prototype and hard to set up currently. 

But: At the moment we are performing a complete rewrite of the project in Rust, with a far easier setup and straightforward usage, so stay tuned.

# Install

First, install [KVM-Nyx](https://github.com/nyx-fuzz/KVM-Nyx). Make sure you are booted into the Nyx-enabled kernel.

```shell
sudo modprobe -r kvm-intel
sudo modprobe -r kvm
sudo modprobe  kvm enable_vmware_backdoor=y
sudo modprobe  kvm-intel
cat /sys/module/kvm/parameters/enable_vmware_backdoor
sudo chmod 777 /dev/kvm 
```

Create a base Ubuntu image for Nyx (the setup is far easier if your host is also an Ubuntu system, even better when it's the same version). Use the [packer](https://github.com/nyx-fuzz/packer) for this step. This creates an Ubuntu 18.04 image with 15GB of HDD and 8GB of RAM.

```shell
./packer/qemu_tool.sh create_image ubuntu_docker.img 15000
./packer/qemu_tool.sh install ubuntu_docker.img ubuntu-18.04.4-server-amd64.iso
    # perform the full installation and then:
	sudo apt-get remove -y docker docker-engine docker.io containerd runc
	sudo apt install -y openssh-server python3 python3-pip libtool-bin bison glib2.0-dev automake docker.io libarchive-dev containerd vmtouch gzip
	sudo usermod -a -G docker $USER
	sudo systemctl unmask docker #bugfix for some
	# logout and login again
	sudo swapoff -a
	shutdown -h now
./packer/qemu_tool.sh post_install ubuntu_docker.img
	scp -P 2222 ./packer/packer/linux_x86_64-userspace/bin64/loader user@localhost:/home/user
	ssh -p 2222 user@localhost
	sudo swapoff -a
	sudo shutdown -h now
./packer/qemu_tool.sh create_snapshot ubuntu_docker.img 8192 ubuntu_docker_pre_snapshot
	sudo swapoff -a
	sudo mv /home/user/loader /tmp
	sudo ./loader	
```

Also build the h*.c files (like hcat, hget etc.) and copy the binaries to fuzzer/webapp_share/.

Adjust the *.ron files in the fuzzer/webapp_share/ directory with the image and snapshot paths. Now the Nyx setup is complete, but we still need to build the fuzzer side of things.

The next installation steps are described in [fuzzer/README.md](fuzzer/README.md).

To start Atropos, you need to build a docker container for the web application under test. See fuzzer/docker-lodel/ for an example of this. Use `docker_build.sh docker-lodel` to create the docker container. This will create a webapp-snapshot.tar.gz file which is then copied into the webapp_share directory. This directory will be accessible from inside the VM, so our agent can use it to start your docker snapshot instance in the VM. See [fuzzer/README.md](fuzzer/README.md) for more information.