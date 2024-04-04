#!/bin/bash
#
# browser.sh - part of the Arch-Setup project
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

cd ..
bash secure.sh
cd MachinePresets
bash base.sh

VIRTUAL_MACHINES_PWD=$PWD

ACTION="Clone, compile, and install yay from the AUR (this may take a while)"
echo -n "...$ACTION..."
cd # pwd -> $HOME
git clone https://aur.archlinux.org/yay.git >/dev/null 2>>/tmp/archsetuperrors.log \
    && cd yay >/dev/null 2>>/tmp/archsetuperrors.log\
    && makepkg -si PKGBUILD --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log\
    && sleep 3 \
    && cd $VIRTUAL_MACHINES_PWD >/dev/null 2>>/tmp/archsetuperrors.log\
        && echo "[SUCCESS]" \
        || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit; }

cd $VIRTUAL_MACHINES_PWD

ACTION="Install librewolf from the AUR (this may take a while)"
echo -n "...$ACTION..."
yay -Sy librewolf-bin --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS]" \
    || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit; }

cd $HOME
exec dwm & librewolf
