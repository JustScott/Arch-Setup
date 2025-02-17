#!/bin/bash
#
# base.sh - part of the Arch-Setup project
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

packages=(
    zip unzip \
    vim neovim \
    lf bat fzf \
    wget base-devel
)

if ! pacman -Q ${packages[@]} &>/dev/null; then
    ACTION="Install packages used by all machine presets"
    echo -n "...$ACTION..."
    sudo pacman -Sy --noconfirm ${packages[@]} >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS]" \
        || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit; }
fi
