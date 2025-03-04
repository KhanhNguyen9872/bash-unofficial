printf "\nUpdating apt....\n"

apt update

for package in build-essential clang make autoconf binutils which unzip git p7zip pv ncurses-utils; do
    printf "\nInstalling ${package}...\n"
    apt install $package -y
done

chmod 777 ./configure
./configure
make -j$(nproc || 2)

if [ -f './bash' ]; then
    printf "\nBuild process completed!\n"
    printf "\nDo you want to install to system? [Y/n]: "
    read choose
    if [[ "$choose" == "Y" ]] || [[ "$choose" == "y" ]]; then
        bash_path=$(which bash)  # Remove spaces around the "=" here
        mv "$bash_path" "$bash_path.old"
        mv ./bash "$bash_path" || { printf "\nFailed when installing to system! You can use this command as root user: `mv ./bash \"$bash_path\"`\n"; exit 0; }
        chmod 777 "$bash_path"
        printf "\nInstalled! Please restart the shell to make it work!\n"
        exit 0
    fi
else
    printf "\nBuild process failed!\n"
fi
