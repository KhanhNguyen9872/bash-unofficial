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
# with older compilers (e.g. GCC < 12 doesn't have -Wdeprecated-non-prototype)
find . -name "Makefile" -not -path "*/examples/*" -not -path "*/po/*" \
    -exec sed -i 's/ -Wdeprecated-non-prototype//g' {} \;

chmod 777 ./configure
make clean
./configure --prefix=$PREFIX

if [ -f ./config.sh ]; then
    source ./config.sh
    if [ -n "$BASH_VERSION" ]; then
        echo "CFLAGS += -DSPOOFED_VERSION='\"$BASH_VERSION\"'" >> Makefile
    fi
    if [ -n "$BASH_MACHTYPE" ]; then
        echo "CFLAGS += -DSPOOFED_MACHTYPE='\"$BASH_MACHTYPE\"'" >> Makefile
    fi
    if [ -n "$BASH_COPYRIGHT" ]; then
        echo "CFLAGS += -DSPOOFED_COPYRIGHT='\"$BASH_COPYRIGHT\"'" >> Makefile
    fi
    if [ -n "$BASH_LICENSE" ]; then
        echo "CFLAGS += -DSPOOFED_LICENSE='\"$BASH_LICENSE\"'" >> Makefile
    fi
    if [ -n "$BASH_WARRANTY" ]; then
        echo "CFLAGS += -DSPOOFED_WARRANTY='\"$BASH_WARRANTY\"'" >> Makefile
    fi
fi

make -j$(nproc || 2)

if [ -f ./bash ]; then
    # Strip debug symbols — removes DWARF sections that leak internal strings
    strip ./bash

    printf "\nBuild process completed!\n"
    printf "\nDo you want to install to system? [Y/n]: "
    read choose
    if [[ "$choose" == "Y" ]] || [[ "$choose" == "y" ]]; then
        bash_path=$(which bash)
        mv "$bash_path" "$bash_path.old"
        mv ./bash "$bash_path" || { printf "\nFailed when installing to system! You can use this command as root user: \`mv ./bash \"$bash_path\"\`\n"; exit 0; }
        chmod 755 "$bash_path"
        printf "\nInstalled! Please restart the shell to make it work!\n"
        exit 0
    else
        printf "\nYou can use it via ./bash, or do whatever you want with the binary.\n"
    fi
else
    printf "\nBuild process failed!\n"
fi
