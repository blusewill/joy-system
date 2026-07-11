#!/bin/sh

# Test Mirror
sudo apt update -y
sudo apt install netselect-apt -y
sudo netselect-apt -c TW -t 2
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
sudo rm /etc/apt/sources.list
sudo cp sources.list /etc/apt/sources.list

# System-Wide Upgrade
sudo apt update -y
sudo apt upgrade -y

# Install Dependency
sudo apt install xorg-dev lightdm dex curl git wget build-essential wget -y
sudo apt install fcitx5 fcitx5-chewing fcitx5-config-qt -y

# Install Chromium
sudo apt install chromium -y

# Git Clone DWM
git clone https://github.com/blusewill/joy-system
cd joy-system/dwm
sudo make install
sudo cp dwm.desktop /usr/share/xsessions/
sudo rm /usr/share/xsessions/lightdm-xsession.desktop
sudo systemctl enable lightdm

# Install Pipewire
sudo apt install wireplumber pipewire pipewire-pulse pipewire-alsa pavucontrol -y
systemctl --user enable wireplumber pipewire pipewire-pulse

# Install Chinese Traditional Font
wget https://github.com/ButTaiwan/gensen-font/releases/download/v2.100/GenSenRounded2TW-otf.zip -O font.zip
mkdir -p $HOME/.local/share/fonts
unzip font.zip $HOME/.local/share/fonts/
rm font.zip
fc-cache -rv

# Moving Detection Script into dotconfig
cd ..
mv autologout.sh $HOME/.config/autologout.sh

# Edit Grub to boot in 0 timeout
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo update-grub
sudo systemctl reboot
