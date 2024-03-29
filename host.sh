#!/bin/bash
#
# host.sh - part of the Arch-Setup project
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


# Just to enable sudo
sudo -v

#----------- Package Manager Setup -----------

ACTION="Install host packages with pacman"
echo -n "...$ACTION..."
sudo pacman -Sy \
    spice-vdagent xclip \
    zip unzip \
    vim neovim \
    lf feh bat \
    newsboat calcurse \
    keepassxc --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS]" \
        || { "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit; }

BACKUP_SCRIPT_DIR=DoNotRun/backup_scripts/host

sudo ln -sf $PWD/$BACKUP_SCRIPT_DIR/pack /usr/local/bin/pack
sudo ln -sf $PWD/$BACKUP_SCRIPT_DIR/unpack /usr/local/bin/unpack

