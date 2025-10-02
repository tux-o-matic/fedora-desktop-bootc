## Fedora workstation image

## Building container

```shell
% podman build -f Containerfile -t fedora-bootc:42
```

## Building qcow2 image

You need to pull the bootc image builder prior to running the build
```shell
podman pull quay.io/centos-bootc/bootc-image-builder:latest
```
```shell
% sudo podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t -v $(pwd)/output:/output -v /var/lib/containers/storage:/var/lib/containers/storage -v ./config.toml:/config.toml:ro quay.io/centos-bootc/bootc-image-builder:latest --type qcow2 --rootfs btrfs localhost/fedora-bootc:42
```

### Running it on arm64
You need an EFI image to boot 
```shell
% qemu-system-aarch64 -name fedora -m 8G -smp 4 -drive file=output/qcow2/disk.qcow2,if=virtio -drive file=flash0.img,format=raw,if=pflash -device virtio-gpu-pci -display default,show-cursor=on -device usb-kbd -device usb-mouse -usb -device qemu-xhci -cpu cortex-a57 -M virt,accel=hvf
```

## Graphical environment 

### guest login
xguest is needed to create transient guest user accounts.
In the Containerfil, when using lightdm for Xfce, the following settings must be appliwed:
```shell
RUN sed -i 's/#allow-guest=true/allow-guest=true/g' /etc/lightdm/lightdm.conf && \
    sed -i 's/#autologin-guest=false/autologin-guest=true/g' /etc/lightdm/lightdm.conf
```