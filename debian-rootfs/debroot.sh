#!/bin/bash
mkdir -p rootfs/bin rootfs/lib rootfs/sbin
debootstrap    bullseye rootfs/
mount -t proc proc rootfs/proc
mount -t sysfs sys rootfs/sys
mount --bind /dev rootfs/dev
cat <<EOF | chroot rootfs/
apt-get update

cat > /etc/locale.gen <<EOF1
en_GB ISO-8859-1
en_GB.ISO-8859-15 ISO-8859-15
en_GB.UTF-8 UTF-8
EOF1

apt-get -y install locales
cat > /etc/default/locale <<EOF2
LC_ALL=en_GB.UTF-8
LANG=en_GB.UTF-8
EOF2
locale-gen 

apt-get -y  --no-install-recommends install vim openssh-server gdisk dosfstools \
	zram-tools wireguard-tools usbutils pciutils iperf iproute2 iw iptables haveged hdparm \
ntp dbus avahi-daemon squashfs-tools

umask 077
mkdir /root/.ssh
cat > /root/.ssh/authorized_keys <<EOF3
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjDpgoJzKLs9ntlt+MmLnxx0xLE+IcUvPo1CuR1uM+cVisKTP4LGqxXUnT7Q+ip6LFUPYR1Y1yaT7Ss9pPjEYRUWdJOK5cfCI13bKn1LuX0m4on9E0JipeptEvTN7W8oCUOb1D9jFZRbDOna98vso5s/pFlRNoXgTmAtUvWuZdupzwU+bdsrIGFxGTVPc9n+WiYgeLX9WNEUh+NX9P7ssh/oD+I4En/CkKC5QoAFFWwhTqL1oYVv1skdtqjHHC3HwKdZnLRE3rDoH1B1QIMjCXabvrqZAydu6PPRA0cZchLldRuvIA+zYh92+HZdJvjBMxLp0bu1nOZzL9exYHDF4D lalith@lalith-Aspire-5742Z
EOF3

cat > /etc/network/interfaces <<EOF4
auto lo
iface lo inet loopback

auto enp1s0
iface enp1s0 inet dhcp 

EOF4

echo "root:1234" | chpasswd 
echo "base" > /etc/hostname

EOF
umount  rootfs/proc rootfs/sys rootfs/dev
# cleanup
rm -rf rootfs/root/.bash_history
rm -rf rootfs/var/cache/apt/archives/*.deb
rm -rf rootfs/var/cache/apt/*.bin
rm -rf rootfs/var/lib/apt/lists/deb.*
for i in rootfs/var/log/*log; do > $i; done

sed -i '/pam_motd.so/d' rootfs/etc/pam.d/sshd
sed -i '/pam_motd.so/d' rootfs/etc/pam.d/login

mksquashfs rootfs/ debian.squash -comp xz
rm -rf rootfs
exit 0
