# How to Dual Boot Windows 10 and Arch Linux

The process is almost the same as installing Arch on a clean disk. There are just some small details that need to be noted when dual booting Windows 10 and Arch.

Installing Windows before Arch is recommended and seems to be the better method for setting up dual boot.

- **Do not create another EFI partition for booting Arch.** 
  - This will prevent you from booting Windows. Instead, mount the EFI partition that was created when you installed Windows and install GRUB there.

- **Run `os-prober` before generating the GRUB config file.** 
  - This will ensure Arch scans and detects all installed OSes on your system. Make sure the Windows partition was detected, then generate the GRUB config file.

- **Disable Fast Startup and hibernation on the Windows partition.** 
  - Data loss can occur if Windows hibernates and you boot into Linux and make changes to files on a filesystem (ie. NTFS) that can be read and written to by Windows and Linux, and that has been mounted by Windows. Data loss can also occur if Linux hibernates, and you dual boot into Windows. Even the EFI partition could become corrupted if Fast Startup and hibernation are turned on when dual booting.
  - In Windows
    - Open Control Panel
    - View by large icons and go to Power Options
    - Click "Choose what the power buttons do" and click "Change settings that are currently unavailable"
    - Disable Fast Startup and hibernation

- **Set both Arch and Windows to use UTC.** 
  - On Windows
    - Run CMD as Admin
      - Run `>reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_QWORD /f`
        - Replace `QWORD` with `DWORD` for 32-bit Windows
  - Arch should be good to go after following the installation guide. Double check the system time by running `$ timedatectl status` in a terminal.
