#!/bin/bash
#
# ollama.sh - part of the Arch-Setup project
# Copyright (C) 2024, JustScott, development@justscott.me
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

if ! [[ $(basename "$PWD") == "NativeLikeAppVMs" ]]
then
    echo "Must be in the Arch-Setup/MachinePresets/NativeLikeAppVMs directory to run this script!"
    exit 1
fi

packages=(ollama)

if ! pacman -Q ${packages[@]} &>/dev/null
then
    ACTION="Install ollama"
    echo -n "...$ACTION..."
    sudo pacman -Sy --noconfirm ${packages[@]} >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS]" \
        || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit; }
fi

sudo systemctl enable --now ollama

ollama pull llama2
ollama pull tinyllama

grep "ollama run llama2" $HOME/.bash_profile &>/dev/null \
    || echo -e "\nollama run llama2" >> $HOME/.bash_profile

cd ..
bash base_vm.sh
