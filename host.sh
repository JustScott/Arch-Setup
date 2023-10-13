#!/bin/bash
#
# host.sh - part of the Arch-Setup project
# Copyright (C) 2023, Scott Wyman, development@scottwyman.me
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


# Just to enable sudo
sudo -v

#----------- Package Manager Setup -----------

cd .. # pwd -> $HOME
git clone https://aur.archlinux.org/yay.git
cd yay # pwd -> $HOME/yay
makepkg -si PKGBUILD --noconfirm
sleep 3
cd ../Arch-Setup # pwd -> $HOME/Arch-Setup

sudo pacman -Sy \
    spice-vdagent \
    zip unzip \
    vim neovim \
    vimb lynx lf \
    bat calcurse newsboat \
    bitwarden keepassxc --noconfirm

# Makes the changes above immediately accessible
newgrp


SCRIPT_DIR=NonUserRunnable/backup_scripts/host

mkdir -p ~/.scripts/general
sudo ln -sf $PWD/$SCRIPT_DIR/pack /usr/local/bin/pack
sudo ln -sf $PWD/$SCRIPT_DIR/unpack /usr/local/bin/unpack

