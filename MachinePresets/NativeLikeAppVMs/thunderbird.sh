#!/bin/bash
#
# thunderbird.sh - part of the Arch-Setup project
# Copyright (C) 2024-2025, JustScott, development@justscott.me
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


#
# You should give the VM plenty of processing power during installation for
#  protonmail & sentry-native compilation
# 

if ! [[ $(basename "$PWD") == "NativeLikeAppVMs" ]]
then
    echo "Must be in the Arch-Setup/MachinePresets/NativeLikeAppVMs directory to run this script!"
    exit 1
fi

packages=(
    thunderbird pass
)

if ! pacman -Q ${packages[@]} &>/dev/null
then
    ACTION="Install Thunderbird"
    echo -n "...$ACTION..."
    sudo pacman -Sy --noconfirm ${packages[@]} >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS]" \
        || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit; }
fi

if ! { which yay || type yay; } &>/dev/null
then
    ACTION="Clone, compile, and install yay from the AUR (this may take a while)"
    echo -n "...$ACTION..."
    cd # pwd -> $HOME
    if git clone https://aur.archlinux.org/yay.git >/dev/null 2>>/tmp/archsetuperrors.log
    then
        {
            cd yay >/dev/null 2>>/tmp/archsetuperrors.log
            makepkg -si PKGBUILD --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log
            cd $VIRTUAL_MACHINES_PWD
        } >/dev/null 2>>/tmp/archsetuperrors.log \
            && echo "[SUCCESS]" \
            || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit; }
    else
        echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"
        exit 1
    fi
fi



yay -Q sentry-native &>/dev/null || yay -Sy --noconfirm sentry-native

yay -Q protonmail-bridge &>/dev/null || yay -Sy --noconfirm protonmail-bridge

# gpg --full-gen-key
# pass init <email>
# protonmail-bridge-core --cli
    # login
    # info
#  127.0.0.1 to avoid error messages

# pass insert <email>

# Run protonmail bridge, login, copy credentials to thunderbird

cd ..
bash base_vm.sh
