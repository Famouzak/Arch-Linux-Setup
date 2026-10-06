#!/bin/bash
set -e

# Load variabel from 01_install.sh
if [ -f /root/install_vars.sh ]; then
  source /root/install_vars.sh
else
  HOSTNAME="archlinux"
  USERNAME="famouzak"
fi

TIMEZONE="Asia/Jakarta"

echo "=== 1. Timezone, Locale & Hostname ==="
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "$HOSTNAME" > /etc/hostname

# Setup /etc/hosts
cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

echo "=== 2. Create Password for User & Root ==="
if ! id -u $USERNAME &>/dev/null; then
  useradd -m -G wheel,video,audio,storage,optical,input -s /bin/bash $USERNAME
fi

echo "Set password for user '$USERNAME':"
passwd $USERNAME
echo "Set password for root:"
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
  pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber pavucontrol easyeffects lsp-plugins-lv2 calf alsa-utils \
  alacritty plasma-meta gwenview okular konsole dolphin kdeconnect kdenlive sddm wayland egl-wayland xdg-user-dirs

echo "=== 5. Install & Setup SDDM Elegant Theme ==="
# Dependency
pacman -S --noconfirm qt6-base qt6-declarative qt6-svg git

# Clean Up
rm -rf /tmp/elegant-sddm /usr/share/sddm/themes/elegant-archlinux /usr/share/sddm/themes/elegant-sddm

# Clone Repository 'elegant-archlinux'
git clone https://github.com/sniper1720/elegant-sddm-archlinux-theme.git /tmp/elegant-sddm
cp -r /tmp/elegant-sddm/elegant-archlinux /usr/share/sddm/themes/
rm -rf /tmp/elegant-sddm

# SDDM Configuration
mkdir -p /etc/sddm.conf.d
cat << 'EOF' > /etc/sddm.conf.d/theme.conf
[Theme]
Current=elegant-archlinux
EOF

echo "=== 6. Bootloader GRUB & Tools Snapper ==="
pacman -S --noconfirm \
  grub efibootmgr grub-btrfs snapper snap-pac inotify-tools os-prober

# Set Kernel Zen as Default
if ! grep -q "GRUB_TOP_LEVEL" /etc/default/grub; then
  echo 'GRUB_TOP_LEVEL="/boot/vmlinuz-linux-zen"' >> /etc/default/grub
fi

# Set Grub Install
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable
grub-mkconfig -o /boot/grub/grub.cfg

echo "=== 7. Enable Services ==="
systemctl enable NetworkManager
systemctl enable sddm
systemctl enable grub-btrfsd

echo "=== 8. Preparation For Post-Install Script ==="
if [ -f /root/scripts/03_postinstall.sh ]; then
  cp /root/scripts/03_postinstall.sh /home/$USERNAME/
  chown $USERNAME:$USERNAME /home/$USERNAME/03_postinstall.sh
  chmod +x /home/$USERNAME/03_postinstall.sh
  echo "File 03_postinstall.sh is moved to /home/$USERNAME/"
fi

echo "=== Chroot Configuration Is Finished! ==="
