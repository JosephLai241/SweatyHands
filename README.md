# How To Install Arch Linux

This is my walkthrough for how I installed **Arch Linux on LVM with encryption, utilizing KDE Plasma** as the desktop environment.

This walkthrough may change as I become more acquainted with Arch.

# Table of Contents

* Installation
	+ [Stage 1](#stage-1)
		* [Clear Existing Partitions](#clear-existing-partitions)
		* [Create New Partitions](#create-new-partitions)
		* [Make Filesystems for EFI and Boot Partitions](#make-filesystems-for-efi-and-boot-partitions)
		* [Encrypt and Make Filesystem for the LVM](#encrypt-and-make-filesystem-for-the-lvm)
		* [Mount Volumes (ALL EXCEPT EFI)](#mount-volumes-all-except-efi)
		* [Get a Network Connection (Wireless Connection)](#get-a-network-connection-wireless-connection)
		* [Edit Mirror List](#edit-mirror-list)
		* [Install `base` Package](#install-base-package)
		* [Generate and Check `fstab` File](#generate-and-check-fstab-file)
		* [Access In-Progress Installation](#access-in-progress-installation)
	+ [Stage 2](#stage-2)
		* [Install Additional Essential Linux packages](#install-additional-essential-linux-packages)
		* [IMPORTANT: Edit `mkinitcpio.conf` File](#important-edit-mkinitcpioconf-file)
		* [Set Timezone and Hardware Clock](#set-timezone-and-hardware-clock)
		* [Set Locale](#set-locale)
		* [Edit `/etc/hosts` and `/etc/hostname`](#edit-etchosts-and-etchostname)
		* [Set Root Password](#set-root-password)
		* [Create Users](#create-users)
		* [Configure GRUB](#configure-grub)
		* [Create SWAPFILE](#create-swapfile)
		* [Configure KDE Plasma](#configure-kde-plasma)
	+ [Stage 3](#stage-3)
* Additional Information
	+ General Maintenance
		* [How to Upgrade and Not Break Your Entire Install]
		* [If You Broke Everything]
	+ LVM
		* [Extending LVM Partitions and LVM Snapshots]
	+ Windows 10
		* [Converting from a full Linux install to Windows 10]
		* [Dual Boot Windows 10 and Arch Linux]

All steps are listed in the order I followed to set up Arch.

---
# Stage 1

All steps are done in the live boot environment.

## Clear Existing Partitions
- `$ fdisk -l`
- Find disk path (probably /dev/sda/ on hard drives)
- `$ fdisk /dev/sda`
- Use option `d` to delete partition, select partition number
  - Repeat until all existing partitions are deleted
  - Use option `p` to list pending changes to system throughout process
- Use option `w` to write changes
  
## Create New Partitions
- The order of my partitions, including partition path, purpose, type, and their corresponding sizes:
  - Partition Path | Partition Purpose | Partition Type | Size
    ---------------|-------------------|----------------|-----
    /dev/sda1 | EFI | EFI | 512MB
    /dev/sda2 | boot | Linux Filesystem | 512MB
    /dev/sda3 | LVM ( /, /home, swapfile) | LVM | Remaining disk
- `$ fdisk /dev/sda`
- Use option `n` to create new partitions.
  - fdisk knows how to number partitions, you can leave it at its default when selecting partition number
  - First sector: enter through
  - Last sector: ex. +512M to make a 512MB partition
    - Simply enter through first and last sector fields if you want to make a partition from the remaining disk space
  - If prompted to remove existing filesystem signature, `y`
  - Use option `t` to set partition type
    - EFI option number: 1
    - Linux filesystem option number: 20. It is also the default so entering through would set this as the partition type
    - Linux LVM option number: 30
  
## Make Filesystems for EFI and boot Partitions
- For /dev/sda1 (EFI)
  - `$ mkfs.fat -F32 /dev/sda1`
- For /dev/sda2 (boot)
  - `$ mkfs.ext4 /dev/sda2`

## Encrypt and Make Filesystem for the LVM 
- `$ cryptsetup luksFormat /dev/sda3`
- "Are you sure?" Well, yeah. So type `YES`
- Enter and re-enter passphrase for encrypted partition
- Open encrypted partition
  - `$ cryptsetup open /dev/sda3 lvm` to open partition as "lvm"
- Create physical volume
  - `$ pvcreate --dataalignment 1m /dev/mapper/lvm`
- Create volume group
  - `$ vgcreate volgroup0 /dev/mapper/lvm` to create volume group "volgroup0"
- Create logical volumes
  - Create / (root)
    - `$ lvcreate -L 32GB volgroup0 -n lv_root` to create logical volume of size 32GB with the name "lv_root"
  - Create /home
    - `$ lvcreate -l 100%FREE volgroup0 -n lv_home` to use the rest of disk with the name "lv_home"
- Make filesystem for LVM groups
  - For / (root)
    - `$ mkfs.ext4 /dev/volgroup0/lv_root`
  - For /home
    - `$ mkfs.ext4 /dev/volgroup0/lv_home`
    
## Mount Volumes (ALL EXCEPT EFI)
- `$ mount /dev/volgroup0/lv_root /mnt` to mount .../lv_root to /mnt
- Create directory in /mnt to mount /home: `$ mkdir /mnt/home`
- `$ mount /dev/volgroup0/lv_home /mnt/home`
- Create directory for boot: `$ mkdir /mnt/boot`
- `$ mount /dev/sda2 /mnt/boot`
- `$ mkdir /mnt/etc` for later use

## Get a Network Connection (Wireless Connection)
- `$ ip a` or `$ ip link` to get wireless interface name
- `$ wifi-menu INTERFACE_NAME` to scan for networks with the interface. Edit the name for the new profile if you want.
- `$ ping A_WEBSITE` to check connection

## Edit Mirror List
- `$ nano /etc/pacman.d/mirrorlist` and move United States mirrors to the top of the list. Pacman prioritizes mirrors at the top of the list, so this would result in a faster download speed.

## Install `base` Package
- `$ pacstrap -i /mnt base`

## Generate and Check `fstab` File
- `$ genfstab -U -p /mnt >> /mnt/etc/fstab` to generate and store the fstab file in /mnt/etc/fstab
- `$ cat /mnt/etc/fstab` and you should see three partitions listed in the file

## Access In-Progress Installation
- `$ arch-chroot /mnt`
- **You can now do the following steps in any order you'd like**

---
# Stage 2

All steps are done in the chroot environment.

## Install Additional Essential Linux packages
- `$ pacman -S base-devel lvm2 linux-firmware man-db man-pages texinfo linux linux-lts linux-headers linux-lts-headers networkmanager wpa_supplicant wireless_tools netctl dialog mesa grub efibootmgr dosfstools os-prober mtools xorg-server plasma-meta kde-applications intel-ucode nano`
  - `lvm2` - **CRITICAL PACKAGE**. Required to boot LVM 
  - `linux` and `linux-lts` gives us kernel options 
  - `linux-headers` and `linux-lts-headers` are optional, but recommended
  - `netctl` is optional. MAY CONFLICT WITH `networkmanager`
  - `mesa` - graphics; provides the DRI driver for 3D acceleration
  - `grub efibootmgr dosfstools os-prober mtools` - necessary packages to install GRUB
  - `plasma-meta kde-applications` - installing KDE Plasma as desktop environment
  - `intel-ucode` - microcode for Intel cpu; or `amd-ucode` for AMD processors
  
## IMPORTANT: Edit `mkinitcpio.conf` File
- `$ nano /etc/mkinitcpio.conf`. The file controls modules and scripts added to the image as well as what happens at boot time.
- Find `HOOKS=(base udev autodetect ...)` line
  - Add "encrypt lvm2" between "block" and "filesystems". **ORDER IS IMPORTANT**
- `$ mkinitcpio -p linux` and `$ mkinitcpio -p linux-lts` if both were installed. You only need to run it against whichever linux package was installed.

## Set Timezone and Hardware Clock
- `$ ln -sf /usr/share/zoneinfo/America/Detroit /etc/localtime`
- `$ hwclock --systohc` to set hardware clock to UTC

## Set Locale
- `$ nano /etc/locale.gen`
  - Uncomment lines that start with "en_US" for United States
- `$ locale-gen`

## Edit `/etc/hosts` and `/etc/hostname`
- Add these lines in `hosts`
  - ```
    127.0.0.1   localhost
    ::1         localhost
    127.0.1.1   arch.localdomain  arch
    ```
- Add this to `hostname`
  - `arch`

## Set Root Password
- `$ passwd`

## Create Users
- `$ useradd -m -g users -G wheel NAME` to create user of NAME in groups `users` and `wheel`
- Set password for user `$ passwd NAME`
- Make user admin
  - Check sudo `$ which sudo`. If DNE, `$ pacman -S sudo`
  - Configure sudo. Create env variable and edit sudo settings `$ EDITOR=nano visudo`
    - Uncomment line that starts with "%wheel ALL" to give users of group `wheel` permission to execute any command
- Repeat and assign privileges as needed.

## Configure GRUB
- `$ nano /etc/default/grub`
- Uncomment "GRUB_ENABLE_CRYPTODISK=y"
- Edit line "GRUB_CMDLINE_LINUX_DEFAULT"
  - Add "cryptdevice=/dev/sda3:volgroup0:allow-discards" between "loglevel=3" and "quiet"
    - **CRITICAL. DO NOT **** UP.**
- `$ mkdir /boot/EFI`
- Finally mount the EFI partition `$ mount /dev/sda1 /boot/EFI`
- `$ grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck`
- `$ mkdir /boot/grub/locale`
- `$ cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo`
- `$ grub-mkconfig -o /boot/grub/grub.cfg`

## Create SWAPFILE
- **SWAPFILE vs Swap Partition**: Can resize at any time whereas resizing a swap partition would be troublesome and risky for system integrity
- `$ fallocate -l 2G /swapfile`
- `$ chmod 600 /swapfile`
- `$ mkswap /swapfile`
- Add SWAPFILE to fstab so that swapfile is initialized during each boot
  - Optional but recommended: make a backup of existing fstab file `$ cp /etc/fstab /etc/fstab.backup`
  - Add SWAPFILE to fstab `$ echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab` to append line to fstab file
- `$ cat /etc/fstab` to check if SWAPFILE was added correctly

## Configure KDE Plasma
- This assumes you've already installed packages `plasma-meta` and `kde-applications`
- `$ systemctl enable sddm`
- `$ systemctl enable NetworkManager`

---
# Stage 3

***Reboot and Pray to God You Didn't **** Something Up***

<!-- Additional Information Links -->

<!-- General Maintenance -->
[How to Upgrade and Not Break Your Entire Install]: https://github.com/JosephLai241/SweatyHands/blob/master/General%20Maintenance/How%20to%20Upgrade%20and%20Not%20Break%20Your%20Entire%20Install.md
[If You Broke Everything]: https://github.com/JosephLai241/SweatyHands/blob/master/General%20Maintenance/If%20You%20Broke%20Everything.md

<!-- LVM -->
[Extending LVM Partitions and LVM Snapshots]: https://www.something.com

<!-- Windows 10 -->
[Dual Boot Windows 10 and Arch Linux]: https://www.something.com
[Converting from a full Linux install to Windows 10]: https://www.something.com
