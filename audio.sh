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

packages=(
    pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse \
    pavucontrol pamixer
)

if ! pacman -Q ${packages[@]} &>/dev/null; then
    sudo pacman -Sy --noconfirm ${packages[@]} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Download and install pipewire audio packages with pacman"
    [[ $? -ne 0 ]] && exit 1 
fi

## If it fails it probably means pulseaudio wasn't installed, so ignore
systemctl --user disable --now pulseaudio &>/dev/null

{
    systemctl --user enable --now pipewire &>/dev/null
    systemctl --user enable --now pipewire-pulse &>/dev/null
} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Enable the pipewire and pipewire-pulse services"
[[ $? -ne 0 ]] && exit 1
