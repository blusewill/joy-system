##!/bin/bash

set -euo pipefail

USER_NAME=$(id -nu 1000)
USER_HOME=$(getent passwd 1000 | cut -d: -f6)

if [ "$EUID" != 0 ]; then
  echo "Please run with sudo."
  exit 1
fi

echo "==============================="
echo " Joy System Installer"
echo "==============================="

echo
echo "[1/9] Selecting Taiwan mirror..."

apt update
apt install -y netselect-apt

TMPDIR=$(mktemp -d)
cd "$TMPDIR"

netselect-apt -c TW -t 2 >sources.list

cp /etc/apt/sources.list /etc/apt/sources.list.backup
cp sources.list /etc/apt/sources.list

echo
echo "[2/9] Updating packages..."

apt update
apt full-upgrade -y

echo
echo "[3/9] Installing packages..."

apt install -y \
  build-essential \
  git \
  curl \
  wget \
  unzip \
  xterm \
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

echo
echo "[4/9] Installing DWM..."

runuser -u "$USER_NAME" -- git clone \
  https://github.com/blusewill/joy-system \
  "$USER_HOME/joy-system" || true

cd "$USER_HOME/joy-system/dwm"

make clean
make
make install

[ -f dwm.desktop ] && cp dwm.desktop /usr/share/xsessions/
[ -f upgrade.desktop ] && cp upgrade.desktop /usr/share/xsessions/

rm -f /usr/share/xsessions/lightdm-xsession.desktop

cp "$USER_HOME/joy-system/lightdm.conf" /etc/lightdm/

systemctl enable lightdm

echo
echo "[5/9] PipeWire..."

runuser -u "$USER_NAME" -- systemctl --user enable --now \
  wireplumber \
  pipewire \
  pipewire-pulse || true

echo
echo "[6/9] GRUB..."

sed -i \
  's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' \
  /etc/default/grub

update-grub

echo
echo "[7/9] User installation..."

runuser -u "$USER_NAME" -- \
  env HOME="$USER_HOME" \
  bash "$USER_HOME/joy-system/user-install.sh"

echo
echo "[8/9] Cleanup..."

apt autoremove -y

echo
echo "[9/9] Finished."

reboot
