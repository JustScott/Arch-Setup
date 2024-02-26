#!/bin/bash
#
# base.sh - part of the Arch-Setup project
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

sudo -v

VIRTUAL_MACHINES_PWD=$(pwd)

ACTION="Clone, compile, and install yay from the AUR"
echo "...$ACTION..."
cd # pwd -> $HOME
git clone https://aur.archlinux.org/yay.git >/dev/null 2>>~/archsetuperrors.log \
    && cd yay >/dev/null 2>>~/archsetuperrors.log\
    && makepkg -si PKGBUILD --noconfirm >/dev/null 2>>~/archsetuperrors.log\
    && sleep 3 \
    && cd $VIRTUAL_MACHINES_PWD >/dev/null 2>>~/archsetuperrors.log\
        && echo "[SUCCESS] $ACTION" \
        || { echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"; exit; }

ACTION="Install Virtual Machine base packages with pacman"
echo "...$ACTION..."
sudo pacman -Sy \
    spice-vdagent \
    zip unzip xclip \
    vim neovim \
    lf bat feh --noconfirm >/dev/null 2>>~/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || { echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"; exit; }
    
# Start the process in the background
spice-vdagent &
