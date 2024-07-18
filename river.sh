#!/bin/bash
#
# river.sh - part of the Arch-Setup project
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


packages=(
    river foot wl-clipboard bemenu-wayland \
    swaybg wlr-randr \
    swayidle waylock \
    pulseaudio pavucontrol brightnessctl pamixer
)

if ! pacman -Q ${packages[@]} &>/dev/null
then
    ACTION="Install river and related packages with pacman (this may take a while)"
    echo -n "...$ACTION..."
    sudo pacman -Sy --noconfirm ${packages[@]} >/dev/null 2>>/tmp/archsetuperrors.log \
            && echo "[SUCCESS]" \
            || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit;} 
fi


# Install or update wm scripts
if [[ -d $PWD/DoNotRun/scripts/wm_scripts ]]
then
    ACTION="Install window manager scripts to /usr/local/bin/"
    sudo ln -sf $PWD/DoNotRun/scripts/wm_scripts/* /usr/local/bin >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"
else
    echo "Please run script from the Arch-Setup base directory"
fi

## .bash_profile runs river on user login
#grep "exec river" $HOME/.bash_profile &>/dev/null || \
#    echo -e "\nexec river &>/dev/null" >> $HOME/.bash_profile

## Only start river if not already running
#if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]]; then
#    cd $HOME
#    exec river >/dev/null 2>>/tmp/archsetuperrors.log \
#        || echo "[FAIL] Starting river... wrote error log to /tmp/archsetuperrors.log"
#fi
