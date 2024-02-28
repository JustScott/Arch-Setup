#!/bin/bash
#
# dwm.sh - part of the Arch-Setup project
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

sudo -v # Enable sudo

# Get the terminal and window manager from suckless
mkdir -p ~/Git/Hub/ArchProjects
cd ~/Git/Hub/ArchProjects # pwd -> $HOME/Git/Hub

ACTION="Clone st"
git clone https://www.github.com/JustScott/st >/dev/null 2>>~/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"
ACTION="Clone dwm"
git clone https://www.github.com/JustScott/dwm >/dev/null 2>>~/archsetuperrors.log\
    && echo "[SUCCESS] $ACTION" \
    || { echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"; exit; } 

ACTION="Compile st"
cd st # pwd -> $HOME/Git/Hub/ArchProjects/st
sudo make install >/dev/null 2>>~/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"

ACTION="Compile dwm"
cd ../dwm # pwd -> $HOME/Git/Hub/ArchProjects/dwm
sudo make install >/dev/null 2>>~/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || { echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"; exit;} 

# Edit .bash_profile and .xinitrc to start dwm on reboot
echo "startx" >> ~/.bash_profile

ACTION="Install dwm related packages with pacman (this may take a while)"
echo -n "...$ACTION..."
sudo pacman -Sy \
    xorg-xrandr xorg-server xorg-xinit xorg-xsetroot \
    libx11 libxinerama libxft \
    pulseaudio pavucontrol brightnessctl pamixer \
    bluez bluez-utils pulseaudio-bluetooth \
    webkit2gtk dmenu picom xscreensaver --noconfirm >/dev/null 2>>~/archsetuperrors.log \
        && echo "[SUCCESS]" \
        || { echo "[FAIL] wrote error log to ~/archsetuperrors.log"; exit;} 

cd ~
# Start dwm
echo "exec dwm" >> ~/.xinitrc
startx >/dev/null 2>>~/archsetuperrors.log || echo "[FAIL] Start X server... wrote error log to ~/archsetuperrors.log"
