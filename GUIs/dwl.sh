#!/bin/bash
#
# dwl.sh - part of the Arch-Setup project
# Copyright (C) 2023-2025, JustScott, development@justscott.me
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

if [[ $(basename $PWD) != "GUIs" ]]
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup/GUIs directory"
    exit 1
fi

source ../shared_lib

bash wm-scripts.sh

packages=(
    libinput wayland wlroots wayland-protocols libxkbcommon wl-clipboard pkg-config \
    foot \
    brightnessctl \
    swayidle waylock \
    swaybg bemenu-wayland \
    wlr-randr fcft tllist
)

# TODO: Run this on pinetab2 sometime to see if still relavent
if uname -r | grep 'pinetab2' &>/dev/null
then
    echo -e "\n - Answer yes to the pulseaudio conflict - \n"
    sudo pacman -S pulseaudio
fi

if ! pacman -Q ${packages[@]} &>/dev/null
then
    ACTION=""
    echo -n "...$ACTION..."
    sudo pacman -Sy --noconfirm ${packages[@]} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" \
        "Download and install dwl related packages with pacman (this may take a while)"
    [[ $? -ne 0 ]] && exit 1 
fi

ARCH_PROJECTS_ROOT=$HOME/Git/Hub/ArchProjects
mkdir -p $ARCH_PROJECTS_ROOT
cd $ARCH_PROJECTS_ROOT # pwd -> $HOME/Git/Hub

if ! { which dwl || type dwl; } &>/dev/null
then
    git clone https://github.com/JustScott/dwl >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Clone dwl to $ARCH_PROJECTS_ROOT/dwl"
    [[ $? -ne 0 ]] && exit 1 

    cd dwl # pwd -> $HOME/Git/Hub/ArchProjects/dwl
    sudo make install >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Install dwl"
    [[ $? -ne 0 ]] && exit 1 
fi

# .bash_profile runs dwl on user login
grep "init-dwl | dwl" $HOME/.bash_profile &>/dev/null || \
    echo -e "\ninit-dwl | dwl &>/dev/null" >> $HOME/.bash_profile

# Only start dwl if not already running
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]]; then
    cd $HOME
    init-dwl | dwl >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" \
        || printf "\e[31m[Error] Issue Starting dwl, check $STDERR_LOG_PATH for details\e[0m\n"
fi
