#!/bin/bash
#
# audio.sh - part of the Arch-Setup project
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

if [[ $(basename $PWD) != "Arch-Setup" ]]
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup base directory"
    exit 1
fi

source ./shared_lib

sudo -v

packages=(
    pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse \
    pavucontrol pamixer
)

if pacman -Q pulseaudio &>/dev/null; then
    if systemctl --user is-active --quiet pulseaudio &>/dev/null
    then
        systemctl --user disable --now pulseaudio &>/dev/null
        task_output $! "$STDERR_LOG_PATH" "Disable and stop pulseaudio service"
    fi

    sudo -v
    yes | sudo pacman -R pulseaudio >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Remove pulseaudio"
    [[ $? -ne 0 ]] && exit 1
fi

if ! pacman -Q ${packages[@]} &>/dev/null; then
    sudo -v
    yes | sudo pacman -Sy ${packages[@]} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Download and install pipewire audio packages with pacman"
    [[ $? -ne 0 ]] && exit 1 
fi

if ! systemctl --user is-enabled pipewire &>/dev/null
then
    systemctl --user enable pipewire \
        >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Enable the pipewire services"
    [[ $? -ne 0 ]] && exit 1
fi

if ! systemctl --user is-active pipewire &>/dev/null
then
    systemctl --user start pipewire \
        >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Start pipewire services"
    [[ $? -ne 0 ]] && exit 1
fi

if ! systemctl --user is-enabled pipewire-pulse &>/dev/null
then
    systemctl --user enable pipewire-pulse \
        >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Enable the pipewire-pulse services"
    [[ $? -ne 0 ]] && exit 1
fi

if ! systemctl --user is-active pipewire-pulse &>/dev/null
then
    systemctl --user start pipewire-pulse \
        >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Start the pipewire-pulse services"
    [[ $? -ne 0 ]] && exit 1
fi
