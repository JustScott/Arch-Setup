#!/bin/bash
#
# river.sh - part of the Arch-Setup project
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

GUIs_PATH=$PWD

source ../shared_lib

sudo -v

bash wm-scripts.sh

packages=(
    wayland-protocols river foot wl-clipboard bemenu-wayland \
    swaybg wlr-randr \
    swayidle swaylock \
    brightnessctl noto-fonts-emoji
)

if uname -m | grep "x86_64" &>/dev/null
then
    packages+=(river-creek)
else
    # creek in pacman only supports x86_64 so compile it with zig
    if ! { which creek || type creek; } &>/dev/null
    then
        if ! pacman -Q zig &>/dev/null
        then
            if ! which yay &>/dev/null
            then
                cd ..
                bash aur.sh
                cd $GUIs_PATH
            fi
            yay -Sy --noconfirm zig-bin fcft pixman wayland \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Download and install zig with pacman"
            [[ $? -ne 0 ]] && exit 1
        fi

        AUR_PROJECTS_ROOT=$HOME/.raw_aur
        mkdir -p $AUR_PROJECTS_ROOT
        cd $AUR_PROJECTS_ROOT

        git clone https://git.8pit.net/creek.git \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Clone Creek"
        [[ $? -ne 0 ]] && exit 1

        cd creek
        zig build >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Compile Creek"
        [[ $? -ne 0 ]] && exit 1

        ln -s $PWD/zig-out/bin/creek ../DoNotRun/scripts/wm_scripts/ \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Install Creek to wm_scripts"
        [[ $? -ne 0 ]] && exit 1
    fi
fi

if ! pacman -Q ${packages[@]} &>/dev/null
then
    sudo -v
    sudo pacman -Sy --noconfirm ${packages[@]} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Download and install river packages with pacman"
    [[ $? -ne 0 ]] && exit 1 
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
