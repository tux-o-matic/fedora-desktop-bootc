# Build a Linux Desktop with bootc

## The architecture
A Gnome based desktop Linux system using Flatpaks as a mean to provide applications for the user.
Upon first boot, a list of popular desktop applications are downloaded in the background. On subsequent boots, the system will check for available updates of those Flatpaks applications.

## Building container

### Fedora
```shell
% podman build -f fedora/Containerfile -t fedora-bootc:43
```

### CentOS Stream
```shell
% podman build -f centos/Containerfile -t centos-bootc:c10s
```

## Creating a VM image

You may want to pull the bootc image builder prior to running the build
```shell
% podman pull quay.io/centos-bootc/bootc-image-builder:latest
```

### Building the qcow2 image
#### Fedora
```shell
% sudo podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t -v $(pwd)/output/fedora:/output -v /var/lib/containers/storage:/var/lib/containers/storage -v ./fedora/config.toml:/config.toml:ro quay.io/centos-bootc/bootc-image-builder:latest --type qcow2 --rootfs btrfs localhost/fedora-bootc:43
```

#### CentOS Stream
```shell
% sudo podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t -v $(pwd)/output/centos:/output -v /var/lib/containers/storage:/var/lib/containers/storage -v ./centos/config.toml:/config.toml:ro quay.io/centos-bootc/bootc-image-builder:latest --type qcow2 localhost/centos-bootc:c10s
```

### Running the image locally (on arm64)
You need an EFI image to boot, here named `flash0.img`.
#### Fedora
```shell
% qemu-system-aarch64 -name fedora -m 8G -smp 4 -drive file=output/fedora/qcow2/disk.qcow2,if=virtio -drive file=flash0.img,format=raw,if=pflash -device virtio-gpu-pci -display default,show-cursor=on -usb -device qemu-xhci -device usb-kbd -device usb-mouse -cpu cortex-a57 -M virt,accel=hvf
```

#### CentOS Stream
```shell
% qemu-system-aarch64 -name centos -m 8G -smp 4 -drive file=output/centos/qcow2/disk.qcow2,if=virtio -drive file=flash0.img,format=raw,if=pflash -device virtio-gpu-pci -display default,show-cursor=on -usb -device qemu-xhci -device usb-kbd -device usb-mouse -cpu cortex-a57 -M virt,accel=hvf
```

## Plymouth boot splash screen
When targetting a physical machine with screen, you can add Plymouth to get a user-friendly boot splash scrren.
To get that, you'll need to use dracut to rebuild the initramfs.
First, install the packages `plymouth plymouth-theme-spinfinity` with dnf in your Containerfile. Then:
```shell
RUN plymouth-set-default-theme spinfinity && \
    mkdir -p /usr/lib/bootc/kargs.d && \
    echo 'kargs = ["quiet", "splash", "rhgb"]' > /usr/lib/bootc/kargs.d/01-splash.toml && \
    kver=$(cd /lib/modules && ls -1 | sort -V | tail -n1) && \
    env DRACUT_NO_XATTR=1 dracut -vf --gzip --no-hostonly --reproducible --add plymouth --add-driver "virtio_gpu simpledrm" /usr/lib/modules/$kver/initramfs.img "$kver"
```
Add the approriate driver for your target such as AMD, nouveau for Nvidia or i915 for Intel.

## Improving boot time
The base image used is a server variant with systemd services enabled that might be of no use for a desktop system on baremetal. Some virtual machine hosting RPMs and services could be removed for desktop. Services related to qemu for example are only useful for a virtual machine.
By using `systemctl disable` in the Containerfile, you can prevent those services from starting at boot time.

## Graphical environment 

### guest login
xguest is needed to create transient guest user accounts.
In the Containerfile, when using lightdm for Xfce, the following settings must be applied:
```shell
RUN sed -i 's/#allow-guest=true/allow-guest=true/g' /etc/lightdm/lightdm.conf && \
    sed -i 's/#autologin-guest=false/autologin-guest=true/g' /etc/lightdm/lightdm.conf
```