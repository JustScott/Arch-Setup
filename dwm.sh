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
mkdir -p ~/Git/Hub
cd ~/Git/Hub # pwd -> $HOME/Git/Hub
git clone https://www.github.com/JustScott/st
git clone https://www.github.com/JustScott/dwm

cd st # pwd -> $HOME/Git/Lab/st
sudo make install

cd ../dwm # pwd -> $HOME/Git/Lab/dwm
sudo make install # Do the initial compilation

# Edit .bash_profile and .xinitrc to start dwm on reboot
echo "startx" >> ~/.bash_profile
echo "exec dwm" >> ~/.xinitrc

# pwd -> $HOME/Arch-Setup
cd ~/Arch-Setup

# Install all the base packages
sudo pacman -Sy xorg-xrandr xorg-server xorg-xinit xorg-xsetroot libx11 libxinerama libxft pulseaudio pavucontrol webkit2gtk dmenu picom xscreensaver pamixer brightnessctl --noconfirm

# For the ytfzf youtube terminal tool
sudo pacman -Sy ytfzf fzf mpv yt-dlp --noconfirm

# Start dwm
startx
