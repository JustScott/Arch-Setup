#!/bin/bash
#
# general-scripts.sh - part of the Arch-Setup project
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

SCRIPT_DIR="$PWD/DoNotRun/scripts/general_scripts"

if ! [[ -d "DoNotRun/scripts/general_scripts" ]]
then
    echo "Please run script from the Arch-Setup base directory"
    exit 1
fi

# Gives all users access to the scripts
#
#ACTION="Install general scripts to /usr/local/bin/"
#sudo ln -sf $PWD/DoNotRun/scripts/general_scripts/* /usr/local/bin >/dev/null 2>>/tmp/archsetuperrors.log \
#    && echo "[SUCCESS] $ACTION" \
#    || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"

# Only gives my user access to the scripts
#
ACTION="Add the general script directory to \$PATH in .bashrc"
{ 
    if ! cat $HOME/.bashrc | grep "export PATH=" | grep "$SCRIPT_DIR" &>/dev/null
    then
        echo "export PATH=\"\$PATH:$SCRIPT_DIR"\" >> $HOME/.bashrc
    fi
} >/dev/null 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"

#
# Will leave this for now as I'm not sure how to dynamically change the shebang
#  in scripts
#
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
