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
echo "[1/11] Selecting Taiwan mirror..."

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
echo "[2/11] Updating packages..."

sudo apt update
sudo apt full-upgrade -y

########################################
# Install Packages
########################################

echo
echo "[3/11] Installing packages..."

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
echo "[4/11] Enabling PipeWire..."

systemctl --user enable --now \
  wireplumber \
  pipewire \
  pipewire-pulse || true

########################################
# Clone Joy System
########################################

echo
echo "[5/11] Downloading Joy System..."

cd "$HOME"

if [ ! -d joy-system ]; then
  git clone https://github.com/blusewill/joy-system
fi

########################################
# Install DWM
########################################

echo
echo "[6/11] Installing DWM..."

cd "$HOME/joy-system/dwm"

make clean

make

sudo make install

if [ -f dwm.desktop ]; then
  sudo cp dwm.desktop /usr/share/xsessions/
fi

if [ -f upgrade.desktop ]; then
  sudo cp upgrade.desktop /usr/share/xsessions/
fi

sudo rm -f /usr/share/xsessions/lightdm-xsession.desktop

sudo rm -f /etc/lightdm/lightdm.conf

cd "$HOME/joy-system"

if [ -f lightdm.conf ]; then
  sudo cp lightdm.conf /etc/lightdm/
fi

sudo systemctl enable lightdm

########################################
# Install Font
########################################

echo
echo "[7/11] Installing GenSenRounded..."

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
echo "[8/11] Copy configuration..."

mkdir -p "$HOME/.config"

if [ -f "$HOME/joy-system/session.sh" ]; then
  cp "$HOME/joy-system/session.sh" \
    "$HOME/.config/session.sh"
  chmod +x "$HOME/.config/session.sh"
fi

if [ -d "$HOME/joy-system/dotconfig" ]; then
  cp -a "$HOME/joy-system/dotconfig/." "$HOME/.config/"
fi

########################################
# GRUB
########################################

echo
echo "[9/11] Configuring GRUB..."

sudo sed -i \
  's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' \
  /etc/default/grub

sudo update-grub

########################################
# Finish
########################################

echo
echo "[10/11] Installing Topgrade for full system upgrade"
echo

curl -s https://api.github.com/repos/topgrade-rs/topgrade/releases/latest | awk -F\" '/topgrade-v.*-x86_64-unknown-linux-gnu.tar.gz/{print $(NF-1)}' | tail -1 | wget -i-

tar xvf topgrade*

mkdir -p $HOME/.local/bin

mv topgrade $HOME/.local/bin/

########################################
# Finish
########################################

echo
echo "[11/11] Done!"
echo

sudo reboot
