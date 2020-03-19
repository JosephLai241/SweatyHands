# How to Convert from Linux to Trash

Obviously talking about Linux to Windows 10.

### Tried and True Method

- [Download .iso file from Microsoft](https://www.microsoft.com/en-us/software-download/windows10ISO)
- Use [WoeUSB](https://github.com/slacka/WoeUSB) to create bootable Windows drive

### Alternative Method (has failed before):

- Format USB drive to NTFS if the Windows .iso file is larger than 4GB. If not, stick to FAT32.
- [Download .iso file from Microsoft](https://www.microsoft.com/en-us/software-download/windows10ISO)
- Make mount point on system `$ sudo mkdir /mnt/WIN10`
- Mount .iso file to mount point to extract installation files `$ sudo mount -o loop /PATH/TO/WINDOWS.ISO /mnt/WIN10`
- Open mount point and copy/paste all files into USB drive
- Get sad and reboot into USB drive

