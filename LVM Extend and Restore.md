# Extending and Restoring LVM

This markdown file goes over how to extend the LVM partitions made in the main .md file and how to create and restore from LVM snapshots.

To list all logical volumes: `$ sudo lvs`

# Extending an LVM Partition

- List available space for extension: `$ sudo vgs`
  - Look at `VFree` section, which lists how much unallocated space is available on the drive
- Make a backup of the system, just in case something happens, before extending the partition
- Extending the LVM Partition with `lvextend`
  - `$ sudo lvextend -L +20g -n /dev/mapper/volgroup0-lv_NAME_OF_LV_TO_EXTEND` - extend logical volume located at /dev/mapper/volgroup0-x by 20GB
- Resize the filesystem with `resize2fs`
  - `$ sudo resize2fs /dev/mapper/volgroup0-lv_NAME_OF_LV_TO_EXTEND` - resize filesystem on the volume to take advantage of new allocated space
  - Run `$ df -h` to check if the size of the logical volume has been extended
  
# LVM Snapshots

## Creating a Snapshot

- `$ sudo lvcreate -L 5GB -s -n 03_15_2020_root_snap /dev/mapper/volgroup0-lv_root` - create a snapshot of the root partition of size 5GB with the name "03_15_2020_root_snap" 
  - `-s` - indicates that the logical volume will be a snapshot
- Check to see if snapshot was created with `$ sudo lvs`. The snapshot will be listed as a logical volume because snapshots are logical volumes.
  
## Restoring from Snapshot

- `$ sudo lvconvert --merge /dev/volgroup0/03_15_2020_root_snap` - restores previously created snapshot
  - Should display "Delaying merge since origin is open". This is because the root partition is still mounted on the system, so you will have to reboot to write the changes.

## Maintaining Snapshots

- `$ sudo lvs`
  - Look at the `Data%` section of the snapshot. This value will continue to increase as more changes are made to the logical volume that corresponds with the snapshot. Make sure this value does not reach 100%, otherwise data will become corrupted.
- Keeping snapshots for long periods of time is not recommended. Good practice would be to make a snapshot before making changes, do extensive testing, then either delete or restore the snapshot depending on the results.

## Removing Snapshots

- `$ sudo lvremove /dev/volgroup0/03_15_2020_root_snap`
- Run `$ sudo lvs` to make sure the snapshot is removed.
