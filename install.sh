#!/bin/bash

set -euo pipefail

########################################
# Joy System Installer
########################################

echo "==============================="
echo " Joy System Installer"
echo "==============================="

########################################
# Root Check
########################################

if ! command -v sudo >/dev/null; then
  echo "sudo not found."
  exit 1
fi

########################################
# Update Mirror
########################################

echo
echo "[1/10] Selecting Taiwan mirror..."

sudo apt update
sudo apt install -y netselect-apt

TMPDIR=$(mktemp -d)
cd "$TMPDIR"

sudo netselect-apt -c TW -t 2 >sources.list

sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

sudo cp sources.list /etc/apt/sources.list

########################################
# Upgrade
########################################

echo
echo "[2/10] Updating packages..."

sudo apt update
sudo apt full-upgrade -y

########################################
# Install Packages
########################################

echo
echo "[3/10] Installing packages..."

sudo apt install -y \
  build-essential \
  git \
  curl \
  wget \
  unzip \
  lightdm \
  xorg-dev \
  chromium \
  fcitx5 \
  volumeicon-alsa \
  fcitx5-chewing \
  fcitx5-config-qt \
  wireplumber \
  pipewire \
  pipewire-pulse \
  pipewire-alsa \
  pavucontrol

########################################
# PipeWire
########################################

echo
echo "[4/10] Enabling PipeWire..."

systemctl --user enable --now \
  wireplumber \
  pipewire \
  pipewire-pulse || true

########################################
# Clone Joy System
########################################

echo
echo "[5/10] Downloading Joy System..."

cd "$HOME"

if [ ! -d joy-system ]; then
  git clone https://github.com/blusewill/joy-system
fi

########################################
# Install DWM
########################################

echo
echo "[6/10] Installing DWM..."

cd "$HOME/joy-system/dwm"

make

sudo make install

if [ -f dwm.desktop ]; then
  sudo cp dwm.desktop /usr/share/xsessions/
fi

sudo rm -f /usr/share/xsessions/lightdm-xsession.desktop

sudo systemctl enable lightdm

########################################
# Install Font
########################################

echo
echo "[7/10] Installing GenSenRounded..."

cd "$HOME"

wget -O font.zip \
  https://github.com/ButTaiwan/gensen-font/releases/download/v2.100/GenSenRounded2TW-otf.zip

mkdir -p "$HOME/.local/share/fonts"

unzip -o font.zip -d "$HOME/.local/share/fonts"

rm font.zip

fc-cache -fv

########################################
# Config
########################################

echo
echo "[8/10] Copy configuration..."

mkdir -p "$HOME/.config"

if [ -f "$HOME/joy-system/autologout.sh" ]; then
  cp "$HOME/joy-system/autologout.sh" \
    "$HOME/.config/autologout.sh"
  chmod +x "$HOME/.config/autologout.sh"
fi

if [ -d "$HOME/joy-system/dotconfig" ]; then
  cp -a "$HOME/joy-system/dotconfig/." "$HOME/.config/"
fi

########################################
# GRUB
########################################

echo
echo "[9/10] Configuring GRUB..."

sudo sed -i \
  's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' \
  /etc/default/grub

sudo update-grub

########################################
# Finish
########################################

echo
echo "[10/10] Done!"
echo

sudo reboot
