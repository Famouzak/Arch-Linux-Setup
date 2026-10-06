#!/bin/bash
set -e

echo "=== 1. Update Directory Default User (XDG) ==="
xdg-user-dirs-update

echo "=== 2. Install YAY (AUR Helper) ==="
if ! command -v yay &> /dev/null; then
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ~
fi

echo "=== 3. Install Gaming & Streaming Tools (Official Repos) ==="
sudo pacman -S --noconfirm \
  steam wine-staging winetricks \
  gamemode lib32-gamemode \
  mangohud lib32-mangohud goverlay lact \
  obs-studio ffmpeg vlc mpv gstreamer \
  gnutls lib32-gnutls giflib lib32-giflib \
  v4l2loopback-dkms v4l2loopback-utils

echo "=== 4. Install Aplikasi AUR (Brave, LACT, Proton-GE) ==="
yay -S --noconfirm \
  brave-bin \
  darkly-bin \
  protonup-qt \
  proton-ge-custom-bin

echo "=== 5. Enable Service LACT (Overclock & Fan Control AMD) ==="
sudo systemctl enable --now lactd

echo "=== 6. Konfigurasi Snapper (Btrfs Snapshots) ==="
sudo umount /.snapshots || true
sudo rm -rf /.snapshots
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots
sudo mkdir -p /.snapshots
sudo mount -a
sudo chmod 750 /.snapshots
sudo chown :wheel /.snapshots

sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
sudo snapper -c root set-config ALLOW_USERS=$USER SYNC_USER=yes

echo "=== 7. Setup Hak Akses HDD WD Blue (/mnt/wdblue) ==="
sudo chown -R $USER:$USER /mnt/wdblue

echo "=== 8. Setup Ocypus Gamma A40 Digital Cooler Display ==="
# Install dependensi Python & HID API
sudo pacman -S --noconfirm python python-pip python-hid python-psutil git

OCYPUS_SRC="/mnt/wdblue/ocypus-a40-digital-linux"

if [ -d "$OCYPUS_SRC" ]; then
  # Copy folder skrip ke home user
  mkdir -p "$HOME/ocypus-a40-digital-linux"
  cp -r "$OCYPUS_SRC"/* "$HOME/ocypus-a40-digital-linux/"
  chmod +x "$HOME/ocypus-a40-digital-linux/ocypus-control.py"

  # Buat udev rule
  sudo bash -c 'cat > /etc/udev/rules.d/99-ocypus-a40.rules << EOF
# Ocypus Gamma A40 ARGB Digital - LCD & RGB Control
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a2c", ATTRS{idProduct}=="434d", GROUP="input", MODE="0660"
EOF'

  # Reload udev
  sudo udevadm control --reload
  sudo udevadm trigger

  # Install & jalankan systemd service (pake sensor k10temp buat Ryzen)
  cd "$HOME/ocypus-a40-digital-linux"
  sudo ./ocypus-control.py install-service -u c -s k10temp -r 2.0 --model gamma
  sudo systemctl daemon-reload
  sudo systemctl enable --now ocypus-lcd.service
  cd ~
  echo "Ocypus LCD Display berhasil dikonfigurasi!"
else
  echo "Peringatan: Folder $OCYPUS_SRC tidak ditemukan di HDD. Setup Ocypus dilewati."
fi

echo "======================================================"
echo "=== Setup Post-Install Selesai! Sistem Siap Pakai. ==="
echo "======================================================"
