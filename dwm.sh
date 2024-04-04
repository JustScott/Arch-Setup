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

# Install or update dwm scripts
[[ -d $PWD/DoNotRun/scripts/dwm_scripts ]] && {
    ACTION="Install dwm scripts to /usr/local/bin/"
    sudo ln -sf $PWD/DoNotRun/scripts/dwm_scripts/* /usr/local/bin >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"
} || {
    echo "Please run script from the Arch-Setup base directory"
}

# Get the terminal and window manager from suckless
mkdir -p ~/Git/Hub/ArchProjects
cd ~/Git/Hub/ArchProjects # pwd -> $HOME/Git/Hub

{ which dwm || type dwm; } &>/dev/null || {
    ACTION="Clone dwm"
    git clone https://www.github.com/JustScott/dwm >/dev/null 2>>/tmp/archsetuperrors.log\
        && echo "[SUCCESS] $ACTION" \
        || { echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"; exit; } 

    ACTION="Compile dwm"
    cd ../dwm # pwd -> $HOME/Git/Hub/ArchProjects/dwm
    sudo make install >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || { echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"; exit;} 
}

{ which st || type st; } &>/dev/null || {
    ACTION="Clone st"
    git clone https://www.github.com/JustScott/st >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"

    ACTION="Compile st"
    cd st # pwd -> $HOME/Git/Hub/ArchProjects/st
    sudo make install >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"
}

# startx runs .xinitrc on user login
grep "startx" $HOME/.bash_profile &>/dev/null || \
    echo -e "\nstartx" >> $HOME/.bash_profile

packages=(
    xorg-xrandr xorg-server xorg-xinit xorg-xsetroot \
    libx11 libxinerama libxft \
    pulseaudio pavucontrol brightnessctl pamixer \
    dmenu picom xscreensaver
)

pacman -Q ${packages[@]} &>/dev/null || {
    ACTION="Install dwm related packages with pacman (this may take a while)"
    echo -n "...$ACTION..."
    sudo pacman -Sy --noconfirm ${packages[@]} >/dev/null 2>>/tmp/archsetuperrors.log \
            && echo "[SUCCESS]" \
            || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit;} 
}

cd $HOME
echo $HOME/.xinitrc | grep "exec dwm" &>/dev/null \
    || echo -e "\nexec dwm" >> ~/.xinitrc
# Only start dwm if not already running
[[ -z "$DISPLAY" ]] && {
    cd $HOME
    startx >/dev/null 2>>/tmp/archsetuperrors.log \
        || echo "[FAIL] Start X server... wrote error log to /tmp/archsetuperrors.log"
}
