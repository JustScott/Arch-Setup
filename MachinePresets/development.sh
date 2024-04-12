#!/bin/bash
#
# development.sh - part of the Arch-Setup project
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

bash base_vm.sh

packages=(python python-pip rustup)

if ! pacman -Q ${packages[@]} &>/dev/null; then
    # Allows for playing videos and music from youtube using the terminal or dmenu
    ACTION="Install development packages"
    echo -n "...$ACTION..."
    sudo pacman -Sy ${packages[@]} --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log\
        && echo "[SUCCESS]" \
        || echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"
fi

ACTION="Configure Rust"
rustup default stable >/dev/null 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"

cd ..
bash secure.sh
bash dwm.sh
