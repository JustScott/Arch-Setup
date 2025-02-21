#!/bin/bash
#
# dwm.sh - part of the Arch-Setup project
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
    xorg-xrandr xorg-server xorg-xinit xorg-xsetroot xclip\
    libx11 libxinerama libxft \
    brightnessctl \
    dmenu picom xscreensaver feh spice-vdagent
)


if ! pacman -Q ${packages[@]} &>/dev/null
then
    sudo pacman -Sy --noconfirm ${packages[@]} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" \
        "Download and install dwm related packages with pacman (this may take a while)"
    [[ $? -ne 0 ]] && exit 1
fi

# Get the terminal and window manager from suckless
ARCH_PROJECTS_ROOT=$HOME/Git/Hub/ArchProjects
mkdir -p $ARCH_PROJECTS_ROOT
cd $ARCH_PROJECTS_ROOT # pwd -> $HOME/Git/Hub

if ! { which dwm || type dwm; } &>/dev/null
then
    ACTION="Clone dwm to $ARCH_PROJECTS_ROOT/dwm"
    git clone https://www.github.com/JustScott/dwm >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Clone dwm"
    [[ $? -ne 0 ]] && exit 1

    cd dwm # pwd -> $HOME/Git/Hub/ArchProjects/dwm
    sudo make install >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Install dwm"
    [[ $? -ne 0 ]] && exit 1
fi

if ! { which st || type st; } &>/dev/null
then
    cd $HOME/Git/Hub/ArchProjects

    ACTION="Clone st to $ARCH_PROJECTS_ROOT/st"
    git clone https://www.github.com/JustScott/st >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"

    ACTION="Compile st"
    cd st # pwd -> $HOME/Git/Hub/ArchProjects/st
    sudo make install >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"
fi

# startx runs .xinitrc on user login
grep "startx" $HOME/.bash_profile &>/dev/null || \
    echo -e "\nstartx &>/dev/null" >> $HOME/.bash_profile

grep "exec dwm" $HOME/.xinitrc &>/dev/null \
    || echo -e "\nexec dwm" >> $HOME/.xinitrc

# Only start dwm if not already running
if [[ -z "$DISPLAY" ]]; then
    cd $HOME
    startx >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" \
        || printf "\e[31m[Error] Issue Starting dwm, check $STDERR_LOG_PATH for details\e[0m\n"
fi
