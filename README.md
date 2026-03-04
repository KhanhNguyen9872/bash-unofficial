# Bash Unofficial

A stealthy, modified version of GNU Bash designed for advanced auditing and forensics. This project implements hidden hooks to log sensitive shell operations while employing multiple evasion techniques to remain undetected by security tools.

## Configuration

Custom spoofing values are managed in `config.sh`, you can rename the `config.sh.example`:

```bash
BASH_VERSION="5.3.0(1)-release"
BASH_MACHTYPE="x86_64-pc-linux-gnu"
BASH_COPYRIGHT="Copyright (C) 2025 Free Software Foundation, Inc."
BASH_LICENSE="License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>\n"
BASH_WARRANTY="This is free software; you are free to change and redistribute it.\nThere is NO WARRANTY, to the extent permitted by law."

# --- Log base directory ---
# Leave empty to use the default (/tmp/ on Linux, Termux /data/data/com.termux/files/usr/tmp/ on Termux)
# All log files (eval.log, exec.log, alias.log, bash_history.log, source.log)
# will be written inside this directory.
log_path=""

# --- Hook enable/disable (1 = enabled, 0 = disabled) ---
hook_eval=1
hook_exec=1
hook_alias=1
hook_source=1
hook_bash_history=0
```

## Branches

The project supports different Bash versions via branches:
- `bash-5.2` (Default & **RECOMMENDED**): Stable and fully tested.
- `bash-5.3`: For those who want the latest features. Just switch to this branch before building.

To switch to Bash 5.3:
```bash
git checkout bash-5.3
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
