#!/bin/bash
#
# dwl.sh - part of the Arch-Setup project
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

bash wm-scripts.sh

packages=(
    libinput wayland wlroots wayland-protocols libxkbcommon wl-clipboard pkg-config \
    foot \
    brightnessctl \
    swayidle waylock \
    swaybg bemenu-wayland \
    wlr-randr fcft tllist
)

if uname -r | grep 'pinetab2' &>/dev/null
then
    echo -e "\n - Answer yes to the pulseaudio conflict - \n"
    sudo pacman -S pulseaudio
fi

if ! pacman -Q ${packages[@]} &>/dev/null
then
    ACTION="Install dwl related packages with pacman (this may take a while)"
    echo -n "...$ACTION..."
    sudo pacman -Sy --noconfirm ${packages[@]} >/dev/null 2>>/tmp/archsetuperrors.log \
            && echo "[SUCCESS]" \
            || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit;} 
fi

ARCH_PROJECTS_ROOT=$HOME/Git/Hub/ArchProjects
mkdir -p $ARCH_PROJECTS_ROOT
cd $ARCH_PROJECTS_ROOT # pwd -> $HOME/Git/Hub

if ! { which dwl || type dwl; } &>/dev/null
then
    ACTION="Clone dwl to $ARCH_PROJECTS_ROOT/dwl"
    git clone https://github.com/JustScott/dwl >/dev/null 2>>/tmp/archsetuperrors.log\
        && echo "[SUCCESS] $ACTION" \
        || { echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"; exit; } 

    ACTION="Compile dwl"
    cd dwl # pwd -> $HOME/Git/Hub/ArchProjects/dwl
    sudo make install >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || { echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"; exit;} 
fi

# .bash_profile runs dwl on user login
grep "init-dwl | dwl" $HOME/.bash_profile &>/dev/null || \
    echo -e "\ninit-dwl | dwl &>/dev/null" >> $HOME/.bash_profile

# Only start dwl if not already running
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]]; then
    cd $HOME
    init-dwl | dwl >/dev/null 2>>/tmp/archsetuperrors.log \
        || echo "[FAIL] Starting dwl... wrote error log to /tmp/archsetuperrors.log"
fi
