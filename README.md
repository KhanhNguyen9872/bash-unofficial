# Bash Unofficial

A stealthy, modified version of GNU Bash designed for advanced auditing and forensics. This project implements hidden hooks to log sensitive shell operations while employing multiple evasion techniques to remain undetected by security tools.

## Configuration

Custom spoofing values are managed in `config.sh`:

```bash
BASH_VERSION="5.2.1(1)-release"
BASH_MACHTYPE="x86_64-pc-linux-gnu"
BASH_COPYRIGHT="Copyright (C) 2022 Free Software Foundation, Inc."
BASH_LICENSE="License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>\n"
BASH_WARRANTY="This is free software; you are free to change and redistribute it.\nThere is NO WARRANTY, to the extent permitted by law."
```

## Build and Install

To build the project on **Linux**:
```bash
sudo bash build.sh
```

To build on **Termux**:
```bash
bash build.sh
```

The script will:
1. Install necessary build dependencies (e.g. `build-essential`, `clang`, `bison`, `flex`).
2. Configure the source for your environment.
3. Inject spoofed version macros from `config.sh` into the build flags.
4. Compile the binary and strip it for maximum stealth.
5. Optionally install it as the system's default shell (moving the original binary to `bash.old`).

## Reverting to Original Bash

If you need to restore the official Bash binary, you have two options:

### Method 1: Restore from Backup
The installation process moves your original bash to `bash.old`. You can restore it manually:
```bash
# On Linux
sudo mv $(which bash).old $(which bash)
# On Termux
mv $(which bash).old $(which bash)
```

### Method 2: Package Reinstallation
Reinstalling the bash package will overwrite the modified binary with the official version:
- **Linux (Debian/Ubuntu)**: `sudo apt reinstall bash`
- **Termux**: `pkg reinstall bash`

## Security Disclaimer

This project is for educational, auditing, and authorized security research purposes only. Unauthorized use on systems without permission is strictly prohibited.
