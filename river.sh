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

bash wm-scripts.sh

packages=(
    wayland-protocols river foot wl-clipboard bemenu-wayland \
    swaybg wlr-randr \
    swayidle waylock \
    brightnessctl
)

if ! pacman -Q pulseaudio zig &>/dev/null
then
    if uname -r | grep 'pinetab2' &>/dev/null
    then
        echo -e "\n - Answer yes to the pulseaudio conflict - \n"
        sudo pacman -S pulseaudio
        sudo pacman -S --noconfirm zig
    fi
fi

if ! pacman -Q ${packages[@]} &>/dev/null
then
    ACTION="Install river and related packages with pacman (this may take a while)"
    echo -n "...$ACTION..."
    sudo pacman -Sy --noconfirm ${packages[@]} >/dev/null 2>>/tmp/archsetuperrors.log \
            && echo "[SUCCESS]" \
            || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit;} 
fi

ARCH_SETUP_DIR=$PWD

AUR_PROJECTS_ROOT=$HOME/.raw_aur
mkdir -p $AUR_PROJECTS_ROOT
cd $AUR_PROJECTS_ROOT # pwd -> $HOME/Git/Hub

if ! { which creek || type creek; } &>/dev/null
then
    # creek in the aur doesn't support aarch64, so compile it with zig
    if uname -r | grep 'pinetab2' &>/dev/null
    then
        ACTION="Build creek from source with zig"
        [[ -d "creek" ]] || git clone https://github.com/nmeum/creek.git
        cd creek
        if zig build; then
            ln -s $PWD/zig-out/bin/creek $ARCH_SETUP_DIR/DoNotRun/scripts/wm_scripts/
            echo "[SUCCESS] $ACTION"
        else
            echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"
            exit 1
        fi
    else
        ACTION="Clone river-creek to $AUR_PROJECTS_ROOT/river-creek"
        git clone https://aur.archlinux.org/river-creek.git >/dev/null 2>>/tmp/archsetuperrors.log\
            && echo "[SUCCESS] $ACTION" \
            || { echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"; exit; } 

        ACTION="Compile river-creek"
        cd river-creek # pwd -> $HOME/.raw_aur/river-creek
        makepkg -si --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log \
            && echo "[SUCCESS] $ACTION" \
            || { echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"; exit;} 
    fi
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
