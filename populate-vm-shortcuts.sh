#!/bin/bash
#
# populate-vm-shortcuts.sh - part of the Arch-Setup project
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

SCRIPT_DIR="$PWD/DoNotRun/scripts/vm_shortcut_scripts"

if ! [[ $(basename "$PWD") == "Arch-Setup" ]]
then
    echo "Must be in the Arch-Setup base directory to run this script!"
    exit 1
fi

ACTION="Add the Virtual Machine shortcut scripts to \$PATH in .bashrc"
{ 
    if ! cat $HOME/.bashrc | grep "export PATH=" | grep "$SCRIPT_DIR" &>/dev/null
    then
        echo "export PATH=\"\$PATH:$SCRIPT_DIR"\" >> $HOME/.bashrc
    fi
} >/dev/null 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"

