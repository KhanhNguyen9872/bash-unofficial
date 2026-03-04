#!/bin/bash

# Function to perform the build process
perform_build() {
    if [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
        if [ "$(id -u)" -ne 0 ]; then
            echo "This script must be run as root user!"
            exit 64
        fi
    fi

    printf "\nUpdating apt....\n"
    apt update

    for package in sudo tsu build-essential clang make autoconf binutils which unzip git p7zip pv ncurses-utils coreutils diffutils findutils gawk grep gzip sed tar texinfo automake bison flex gettext libiconv ncurses; do
        printf "\nInstalling ${package}...\n"
        apt install $package -y
    done

    if [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
        apt --purge remove gcc g++ -y;
        ln -sf "$(which clang)" /usr/bin/gcc
        ln -sf "$(which clang)" /usr/bin/g++
    fi

    # Strip unsupported GCC flags from Makefiles to ensure compatibility
    find . -name "Makefile" -not -path "*/examples/*" -not -path "*/po/*" \
        -exec sed -i 's/ -Wdeprecated-non-prototype//g' {} \;

    chmod 777 ./configure
    make clean
    sed -i 's/-Wdeprecated-non-prototype//g' configure
    ./configure --prefix=$PREFIX ac_cv_func_memfd_create=no

    if [ -f ./config.sh ]; then
        source ./config.sh
        # (Inject spoofed macros - logic remains same)
        [ -n "$BASH_VERSION" ] && echo "CFLAGS += -DSPOOFED_VERSION='\"$BASH_VERSION\"'" >> Makefile
        [ -n "$BASH_MACHTYPE" ] && echo "CFLAGS += -DSPOOFED_MACHTYPE='\"$BASH_MACHTYPE\"'" >> Makefile
        [ -n "$BASH_COPYRIGHT" ] && echo "CFLAGS += -DSPOOFED_COPYRIGHT='\"$BASH_COPYRIGHT\"'" >> Makefile
        [ -n "$BASH_LICENSE" ] && echo "CFLAGS += -DSPOOFED_LICENSE='\"$BASH_LICENSE\"'" >> Makefile
        [ -n "$BASH_WARRANTY" ] && echo "CFLAGS += -DSPOOFED_WARRANTY='\"$BASH_WARRANTY\"'" >> Makefile

        if [ -n "$log_path" ]; then _log_base="$log_path"; elif [[ "$PREFIX" == "/data/data/com.termux/files/usr" ]]; then _log_base="/data/data/com.termux/files/usr/tmp"; else _log_base="/tmp"; fi
        echo "CFLAGS += -DLOG_BASE_PATH='\"$_log_base\"'" >> Makefile
        echo "CFLAGS += -DLOG_BASE_PATH='\"$_log_base\"'" >> builtins/Makefile

        for hook in hook_eval hook_exec hook_alias hook_bash_history hook_source; do
            val="${!hook}"
            [ -z "$val" ] && { [ "$hook" == "hook_bash_history" ] && val=0 || val=1; }
            macro=$(echo "$hook" | tr '[:lower:]' '[:upper:]')
            cflags_line="CFLAGS += -D${macro}=${val}"
            echo "$cflags_line" >> Makefile
            echo "$cflags_line" >> builtins/Makefile
        done
    fi

    make -j$(nproc || 2)
    if [ -f ./bash ]; then
        strip ./bash
        printf "\nBuild process completed!\n"
    else
        printf "\nBuild process failed!\n"
        exit 1
    fi
}

# Function to perform installation
perform_install() {
    if [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
        if [ "$(id -u)" -ne 0 ]; then
            echo "This script must be run as root user to install!"
            exit 64
        fi
    fi

    bash_path=$(which bash)
    printf "\nBacking up original bash to $bash_path.old...\n"
    cp "$bash_path" "$bash_path.old"

    if [ ! -f ./bash ]; then
        printf "\nBinary not found, building first...\n"
        perform_build
    fi

    printf "\nInstalling using make install...\n"
    # Ensure PREFIX is set correctly for Linux if not in Termux
    # If PREFIX is empty and we are on Linux, we might need to set it to /usr or /
    # But we'll trust the user has configured it or is fine with default /usr/local
    make install

    # If make install put it in a different place, the system might still use the old one.
    # We should alert the user if which bash still points to the old one if they didn't set PREFIX.
    new_bash_path=$(which bash)
    chmod 755 "$new_bash_path"
    printf "\nInstalled! Please restart the shell to make it work!\n"
    printf "Current bash path: $new_bash_path\n"
}

# Handle command line arguments
case "$1" in
    "bash-5.2"|"bash-5.3")
        printf "\nSwitching to branch $1...\n"
        if ! git checkout "$1"; then
            printf "\nFailed to switch to branch $1! Do you want to reset the repository and try again? [Y/n]: "
            read reset_choice
            if [[ "$reset_choice" == "Y" ]] || [[ "$reset_choice" == "y" ]]; then
                git reset --hard HEAD
                git clean -fd
                git checkout "$1" || { echo "Failed to switch even after reset!"; exit 1; }
            else
                echo "Switch failed. Exiting."
                exit 1
            fi
        fi
        perform_build
        ;;
    "install")
        perform_install
        exit 0
        ;;
    "reset")
        printf "\nResetting repository...\n"
        git reset --hard HEAD
        git clean -fd
        exit 0
        ;;
    "pull")
        printf "\nPulling latest changes...\n"
        git pull
        exit 0
        ;;
    "")
        perform_build
        
        printf "\nDo you want to install to system? [Y/n]: "
        read choose
        if [[ "$choose" == "Y" ]] || [[ "$choose" == "y" ]]; then
            perform_install
        else
            printf "\nYou can use it via ./bash, or do whatever you want with the binary.\n"
        fi
        ;;
    *)
        echo "Usage: $0 [bash-5.2 | bash-5.3 | install | reset | pull]"
        exit 1
        ;;
esac
