# Arch Linux installation for meushi (2021.02)

Reference: https://wiki.archlinux.org/index.php/Installation_guide

## BIOS

* Boot\CSM disabled
* Boot\Secure Boot set to Other OS

## Basic install

* Boot on a USB key with Arch Linux ISO (not netinstall)

```loadkeys fr```

* Create disk layout

```
Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: Samsung SSD 860 
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: F9E0FD17-177D-11EB-9E5A-DD0136727040

Device         Start        End    Sectors   Size Type
/dev/sda1       2048    1128447    1126400   550M EFI System
/dev/sda2    1128448  195312500  194184053  92.6G Linux root (x86-64)
/dev/sda3  195313664 1953523711 1758210048 838.4G Linux user's home
```

* Create filesystems

```
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
```

* Bootstrap ArchLinux

```
mount /dev/sda2 /mnt
mkdir -p /mnt/boot/EFI
mount /dev/sda1 /mnt/boot/EFI
pacstrap /mnt base linux linux-firmware vim
genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt
```

* Set time zone

```
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
```

* Generate locale

In **/etc/locale.gen**, uncomment:

```
en_US.UTF-8
fr_FR.UTF-8
```

```
locale-gen
```

* Set the keyboard layout  

Create **/etc/vconsole.conf**

```
KEYMAP=fr
```

* Set hostname

Create **/etc/hostname**

```
meushi
```

Edit **/etc/hosts**

```
127.0.0.1   localhost
::1		    localhost
127.0.1.1	meushi.localdomain	meushi
```

* Set root password

```
passwd
```

* Setup systemd-boot with AMD microcode

```
bootctl install
cp /usr/share/systemd/bootctl/arch.conf /boot/efi/loader/entries/arch-lts.conf
```

Adapt **/boot/efi/loader/entries/arch-lts.conf**

```
title   Arch Linux LTS
linux   /vmlinuz-linux-lts
initrd  /amd-ucode.img
initrd  /initramfs-linux-lts.img
options root=UUID=78da4ebd-5eba-4a7c-8caf-5f297eece0a7 rootfstype=ext4 add_efi_memmap
```

**Note**: find UUID with ```blkid```.

Edit **/boot/efi/loader/loader.conf**:

```
timeout 3
console-mode max
default arch-lts.conf
```

Check configuration with ```bootctl list```

* Reboot

```
exit
reboot
```

## Network connection

Login as **root** and setup network

```
systemctl enable NetworkManager
systemctl start NetworkManager
```

## User creation

```
pacman -S zsh sudo base-devel git python3
groupadd -g 1000 viny
useradd -m -G wheel -u 1000 -g 1000 -s /bin/zsh viny
passwd viny
```

In **/etc/sudoers** uncomment:

```
%wheel ALL=(ALL) ALL
```

## Setup encrypted partition for user home

```
cryptsetup luksFormat /dev/sda3
cryptsetup open /dev/sda3 home-viny
mkfs.ext4 /dev/mapper/hom-viny
```

```
mkdir /home/viny
mount -t ext4 /dev/mapper/home-viny /home/viny
```

Edit **/etc/pam.d/system-login**

```
...
auth       include    system-auth
auth       optional   pam_exec.so expose_authtok /etc/pam_cryptsetup.sh

account    required   pam_access.so
...
```

Create executable script **/etc/pam_cryptsetup.sh**:

```
#!/bin/sh

CRYPT_USER=viny"
PARTITION="/dev/sda3"
NAME="home-$CRYPT_USER"

if [ "$PAM_USER" == "$CRYPT_USER" ] && [ ! -e "/dev/mapper/$NAME" ]; then
    /usr/bin/cryptsetup open $PARTITION $NAME
fi
```

Create **/etc/systemd/system/home-viny.mount**:

```
[Unit]
Requires=user@1000.service
Before=user@1000.service

[Mount]
Where=/home/viny
What=/dev/mapper/home-viny
Type=ext4
Options=defaults

[Install]
RequiredBy=user@1000.service
```

**Note**: locking after unmout will be setup later with Ansible.
