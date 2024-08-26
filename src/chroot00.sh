# bash script to run bash shell in chroot jailed environment
# to run script:
# chmod +x chroot00.sh
# ./chroot00.sh

# create a directory to hold the chroot environment
mkdir -p /home/namespace/box

# create dirs to hold some essential libs and binaries
mkdir -p /home/namespace/box/bin
mkdir -p /home/namespace/box/lib
mkdir -p /home/namespace/box/lib64

#copy the bash binary and some useful binaries like ps and kill
cp -v /bin/bash /home/namespace/box/bin/
cp -v /usr/bin/kill /home/namespace/box/bin
cp -v /usr/bin/ps /home/namespace/box/bin
cp -v /bin/ls /home/namespace/box/bin

# copy the required libraries
cp -r /lib/* /home/namespace/box/lib
cp -r /lib64/* /home/namespace/box/lib64

# mount the proc filesystem to chroot environment
mount -t proc proc /home/namespace/box/proc

# run the bash shell in chroot environment
chroot /home/namespace/box !#/bin/bash

