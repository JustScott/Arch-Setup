#!/bin/bash
#
# development_apps.sh - part of the Arch-Setup project
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
bash user.sh
bash secure.sh
cd VirtualMachines
bash base.sh

ACTION="Install browsers from the AUR (this may take a while)"
echo -n "...$ACTION..."
yay -Sy librewolf-bin vimb --noconfirm >/dev/null 2>>~/archsetuperrors.log \
    && echo "[SUCCESS]" \
    || { echo "[FAIL] wrote error log to ~/archsetuperrors.log"; exit; }

SCRIPT_DIR=../DoNotRun/backup_scripts/development_apps

sudo ln -sf $PWD/$SCRIPT_DIR/pack /usr/local/bin/pack
sudo ln -sf $PWD/$SCRIPT_DIR/unpack /usr/local/bin/unpack

cd ..
bash dwm.sh
