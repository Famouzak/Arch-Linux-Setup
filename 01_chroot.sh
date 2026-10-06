#!/bin/bash
set -e

HOSTNAME="archlinux"
USERNAME="famouzak"
TIMEZONE="Asia/Jakarta"

echo "=== 1. Timezone & Locale ==="
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "$HOSTNAME" > /etc/hostname

echo "=== 2. Create User & Sudo ==="
useradd -m -G wheel,video,audio,storage,optical,input -s /bin/bash $USERNAME
echo "Set password untuk user '$USERNAME':"
passwd $USERNAME
echo "Set password untuk root:"
passwd
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "=== 3. Enable Multilib Repo ==="
sed -i "/\[multilib\]/,/Include/ s/^#//" /etc/pacman.conf
pacman -Sy

echo "=== 4. Drivers AMD RX 5700 XT, Audio PipeWire & KDE Plasma 6 ==="
pacman -S --noconfirm \
  mesa lib32-mesa \
  vulkan-radeon lib32-vulkan-radeon \
  libva-mesa-driver lib32-libva-mesa-driver \
  lib32-vulkan-icd-loader vulkan-icd-loader \
  pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber pavucontrol easyeffects lsp-plugins-lv2 calf \
  alacritty plasma-meta konsole dolphin kdeconnect kdenlive sddm wayland egl-wayland xdg-user-dirs

echo "=== 5. Install & Setup Tema SDDM Elegant ==="
pacman -S --noconfirm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg git
git clone https://github.com/sniper1720/elegant-sddm-archlinux-theme.git /usr/share/sddm/themes/elegant-sddm

mkdir -p /etc/sddm.conf.d
cat << 'EOF' > /etc/sddm.conf.d/theme.conf
[Theme]
Current=elegant-sddm
EOF

echo "=== 6. Bootloader GRUB & Tools Snapper ==="
pacman -S --noconfirm \
  grub efibootmgr grub-btrfs snapper snap-pac inotify-tools os-prober

# Set Kernel Zen sebagai default di GRUB
echo 'GRUB_TOP_LEVEL="/boot/vmlinuz-linux-zen"' >> /etc/default/grub

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "=== 7. Enable Services ==="
systemctl enable NetworkManager
systemctl enable sddm
systemctl enable grub-btrfsd

echo "=== Chroot Configuration Selesai! ==="
