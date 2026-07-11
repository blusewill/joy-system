#!/bin/sh

ROOT = $(PWD)

# Test Mirror
sudo apt update -y
sudo apt install netselect-apt -y
netselect-apt -c TW -t 2
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
sudo rm /etc/apt/sources.list
sudo cp sources.list /etc/apt/sources.list

# System-Wide Upgrade
sudo apt update -y
sudo apt upgrade -y

# Install Dependency
sudo apt install xorg-dev lightdm dex curl git wget build-essential -y
sudo apt install fcitx5 fcitx5-chewing fcitx5-qt fcitx5-gtk -y

# Install Chromium
sudo apt install chromium -y

# Git Clone DWM
git clone https://github.com/blusewill/joy-system
cd joy-system/dwm
sudo make install
sudo systemctl enable lightdm

# Clone autostart file
cd ..
cp autostart/* $HOME/.config/autostart/
