# Arch-Linux-Setup
This is for personal use only by Famouzak, Use it with your own risk.
This scrypt was made with the help of AI for AMD System and intended to make install Arch linux for Famouzak easier to Gaming & Streaming.

This Installer Scrypt are made by reading Arch Wiki Installation Guide.

My PC Specs ;

AMD RYZEN 5 5600
GIGABYTE B550M-K REV 1.0
GIGABYTE AORUS RX 5700 XT REV 2.0
KLEVV BOLT XR 2X8 GB DDR4 MEMORY
WD BLACK SN750 256 GB NVME GEN 4X4
WD BLUE 500 GB HDD
THERMALRIGHT TR KG-650 W GOLD
CPU COOLER : OCYPUS GAMMA A40 DIGITAL ARGB

PERIPHERAL
GIGABYTE GS25F2 200 HZ GAMING MONITOR
LOGITECH G102
LOGITECH MK120
LOGITECH SPEAKER
FIFINE H3 HEADPHONE
BONKYO M999 CONDENSER MIC

Arch Linux Setup :

== KERNEL ==
ARCH LINUX ZEN (Default)
ARCH LINUX
ARCH LINUX-LTS

== BOOTLOADER ==
GRUB

== DESKTOP ENVIRONTMENT ==
KDE PLASMA (PLASMA-META)

== AUDIO ==
PIPEWIRE

== FILE SYSTEM ==
BTRFS With snapper
SWAP 4 GB

NVME = BTRFS , HDD = EXT4

== Apps ==
Pacman ; Steam, Obs-Studio, Lact,  Goverlay, Pavucontrol, Easyeffects, Kdenlive, Dolphin, Gwenview, Okular, Vlc, Mpv

AUR ; Brave Browser , Darkly-Bin

== SCRYPTS ==
Custom Scrypt to Run LED CPU MONITORING for OCYPUS A40 GAMMA

=============================================
        HOW TO USE THIS SCRYPTS
=============================================

BOOT INTO ARCH LINUX LIVE ISO

$ pacman -Sy
$ pacman -Sy git reflector

Clone the Repo

$ git clone https://github.com/Famouzak/Arch-Linux-Setup.git


$ cd Arch-Linux-Setup
$ chmod +x *.sh

Run the Scrypt

$./01_install.sh

After Step 01, Then Run Step 02

# 1. Copy the Scrypt
$ cp -r . /mnt/root/scripts

# 2. arch-chroot environment
$ arch-chroot /mnt

# 3. Go to Scrypts Foldef
$ cd /root/scripts

# 4. Run the Scrypts
$ ./02_chroot.sh


PREPARATION BEFORE EXITING CHROOT

$ cp 03_postinstall.sh /home/famouzak/

$ chown famouzak:famouzak /home/famouzak/03_postinstall.sh

$ exit
$ umount -R /mnt
$ reboot



