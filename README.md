# Bash Unofficial

A stealthy, modified version of GNU Bash designed for advanced auditing and forensics. This project implements hidden hooks to log sensitive shell operations while employing multiple evasion techniques to remain undetected by security tools.

## Features

- **Sensitive Operation Logging**: Automatically logs calls to `eval`, `exec`, `alias`, and general command execution.
- **Stealth & Evasion**:
    - **Path Obfuscation**: Log file paths are stored as XOR-encoded byte arrays and decrypted only in memory at runtime, making them invisible to `strings` scans.
    - **Symbol Obfuscation**: Critical internal logging functions are renamed to generic equivalents (e.g., `flush_ctx`, `record_expr`, `record_sym`) to blend in with standard Bash source code.
    - **Binary Stripping**: The build process automatically strips debug symbols and DWARF sections to eliminate internal string leakage.
    - **No Banners**: Removed the default "unofficial" banners and identifiable author strings from the shell environment.
- **Version Spoofing**: Fully configurable version information via `config.sh`. Spoof the version string, architecture, copyright year, and license text to match any legitimate Bash release.
- **Automated Build System**: A comprehensive `build.sh` script that manages dependencies, patches Makefiles for compiler compatibility, and handles system-wide installation.

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

To build the project:

```bash
sudo bash build.sh
```

The script will:
1. Install necessary build dependencies.
2. Configure the source for your environment.
3. Inject the spoofed version macros from `config.sh` into the build flags.
4. Compile the binary and strip it for maximum stealth.
5. Optionally install it as the system's default shell (moving the original to `bash.old`).

## Logs

Logs are written to hidden paths (configured in `log_path_helper.h`). By default, they are stored in the user's home directory under an obfuscated structure to avoid detection by standard file system scanners.

## Security Disclaimer

This project is for educational, auditing, and authorized security research purposes only. Unauthorized use on systems without permission is strictly prohibited.
