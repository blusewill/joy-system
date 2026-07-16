#!/bin/bash

set -euo pipefail

echo
echo "User Installation"

cd "$HOME"

if [ ! -d joy-system ]; then
  git clone https://github.com/blusewill/joy-system
fi

echo
echo "Installing Fonts..."

wget -O font.zip \
  https://github.com/ButTaiwan/gensen-font/releases/download/v2.100/GenSenRounded2TW-otf.zip

mkdir -p ~/.local/share/fonts

unzip -o font.zip -d ~/.local/share/fonts

rm font.zip

fc-cache -fv

echo
echo "Copy Config..."

mkdir -p ~/.config

cp ./joy-system/session.sh ~/.config/
chmod +x ~/.config/session.sh

cp -a dotconfig/. ~/.config/

echo
echo "Installing Topgrade..."

mkdir -p ~/.local/bin

curl -s https://api.github.com/repos/topgrade-rs/topgrade/releases/latest |
  awk -F\" '/topgrade-v.*-x86_64-unknown-linux-gnu.tar.gz/{print $(NF-1)}' |
  tail -1 |
  wget -i-

tar xvf topgrade*

mv topgrade ~/.local/bin/

echo
echo "User Installation Finished."
