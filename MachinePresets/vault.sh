#!/bin/bash
#
# vault.sh - part of the Arch-Setup project
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

if ! [[ $(basename "$PWD") == "MachinePresets" ]]
then
    echo "Must be in the Arch-Setup/MachinePresets directory to run this script!"
    exit 1
fi

bash base_vm.sh

packages=(pass)

if ! pacman -Q ${packages[@]} &>/dev/null; then
    # Allows for playing videos and music from youtube using the terminal or dmenu
    ACTION="Install Vault packages with pacman"
    echo -n "...$ACTION..."
    sudo pacman -Sy ${packages[@]} --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log\
        && echo "[SUCCESS]" \
        || echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"
fi

cd ..
bash secure.sh
