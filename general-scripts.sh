#!/bin/bash
#
# general-scripts.sh - part of the Arch-Setup project
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

if ! [[ -d $PWD/DoNotRun/scripts/general_scripts ]]
then
    echo "Please run script from the Arch-Setup base directory"
    exit 1
fi

ACTION="Install general scripts to /usr/local/bin/"
sudo ln -sf $PWD/DoNotRun/scripts/general_scripts/* /usr/local/bin >/dev/null 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"

ACTION="Place supporting script data in /usr/local/script_data"
{
    if ! [[ -d $PWD/DoNotRun/scripts/script_data/timer/.venv ]]
    then
        python3 -m venv DoNotRun/scripts/script_data/timer/.venv
    fi
    DoNotRun/scripts/script_data/timer/.venv/bin/pip install -r DoNotRun/scripts/script_data/timer/requirements.txt 

    sudo mkdir -p /usr/local/script_data
    sudo ln -sf $PWD/DoNotRun/scripts/script_data/timer /usr/local/script_data/timer
} >/dev/null 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"
