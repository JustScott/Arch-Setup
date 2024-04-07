#!/bin/bash
#
# neomutt.sh - part of the Arch-Setup project
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

STARTING_PWD=$PWD

packages=(
    neomutt curl isync \
    msmtp pass ca-certificates \
    gettext
)

pacman -Q ${packages[@]} &>/dev/null || {
    ACTION="Install neomutt & its dependencies"
    echo -n "...$ACTION..."
    sudo pacman -Sy --noconfirm ${packages[@]} >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS]" \
        || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit; }
}


[[ -d $HOME/pam-gnupg ]] || {
    cd $HOME
    git clone https://aur.archlinux.org/pam-gnupg.git
    cd pam-gnupg
    makepkg -si --noconfirm
}

[[ -d $HOME/mutt-wizard ]] || {
    cd $HOME
    git clone https://github.com/LukeSmithxyz/mutt-wizard
    cd mutt-wizard
    sudo make install
}

cd $STARTING_PWD

cd ..
bash base_vm.sh

