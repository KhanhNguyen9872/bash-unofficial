printf "\nUpdating apt....\n"

apt update

for package in build-essential clang make autoconf binutils which unzip git p7zip pv ncurses-utils; do
    printf "\nInstalling ${package}...\n"
    apt install $package -y
done


./configure
make -j$(nproc || 2)

if [ -f './bash' ]; then
    printf "\nBuild process completed!\n"
else
    printf "\nBuild process failed!\n"
fi