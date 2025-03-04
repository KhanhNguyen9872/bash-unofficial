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
    printf "\nDo you want install to system? [Y/n]: "
    read -p choose
    if [[ "$choose" == "Y" ]] || [[ "$choose" == "y" ]]; then
        bash_path = "$(which bash)"
        mv "$bash_path" "$bash_path.old"
        cp ./bash "$bash_path" || printf "\nFailed when install to system! You can using this command in root user: `cp ./bash \"$bash_path\"`\n"
        chmod 777 "$bash_path"
    fi
else
    printf "\nBuild process failed!\n"
fi
