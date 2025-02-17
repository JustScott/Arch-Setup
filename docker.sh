#!/bin/bash
#
# docker.sh - part of the Arch-Setup project
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


packages=(docker docker-compose)

if ! pacman -Q ${packages[@]} &>/dev/null; then
    ACTION="Install docker and docker-compose"
    echo -n "...$ACTION..."
    sudo pacman -Sy  --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS]" \
        || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit; }
fi

ACTION="Configure Docker"
if sudo systemctl enable --now docker >/dev/null 2>>/tmp/archsetuperrors.log
then
    sudo usermod -aG docker $USER >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"
fi

if [[ -f $HOME/.bashrc ]]; then
    ACTION="Set Docker defaults in $HOME/.bashrc"
    {
        cat $HOME/.bashrc | grep "export DOCKER_BUILDKIT=1" >/dev/null || \
            echo -e "\nexport DOCKER_BUILDKIT=1" >> $HOME/.bashrc
        cat $HOME/.bashrc | grep "export COMPOSE_DOCKER_CLI_BUILD=1" >/dev/null || \
            echo -e "export COMPOSE_DOCKER_CLI_BUILD=1\n" >> $HOME/.bashrc
    } >/dev/null 2>>/tmp/archconfigurationerrors.log \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"
fi

