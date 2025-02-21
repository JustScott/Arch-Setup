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

if [[ $(basename $PWD) != "Arch-Setup" ]]
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup base directory"
    exit 1
fi

source ./shared_lib

SCRIPT_DIR="$PWD/DoNotRun/scripts/general_scripts"

# Gives all users access to the scripts
#
#ACTION="Install general scripts to /usr/local/bin/"
#sudo ln -sf $PWD/DoNotRun/scripts/general_scripts/* /usr/local/bin >/dev/null 2>>/tmp/archsetuperrors.log \
#    && echo "[SUCCESS] $ACTION" \
#    || echo "[FAIL] $ACTION... wrote error log to /tmp/archsetuperrors.log"

# Only gives my user access to the scripts
#
if ! cat $HOME/.bashrc | grep "export PATH=" | grep "$SCRIPT_DIR" &>/dev/null
then
    echo "export PATH=\"\$PATH:$SCRIPT_DIR"\" >> $HOME/.bashrc \
        >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Add the general script directory to \$PATH in .bashrc"
    [[ $? -ne 0 ]] && exit 1
fi

#
# Will leave this for now as I'm not sure how to dynamically change the shebang
#  in scripts
#
{
    if ! [[ -d $PWD/DoNotRun/scripts/script_data/timer/.venv ]]
    then
        python3 -m venv DoNotRun/scripts/script_data/timer/.venv
    fi
    DoNotRun/scripts/script_data/timer/.venv/bin/pip install -r DoNotRun/scripts/script_data/timer/requirements.txt 

    sudo mkdir -p /usr/local/script_data
    sudo ln -sf $PWD/DoNotRun/scripts/script_data/timer /usr/local/script_data/timer
} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Place supporting script data in /usr/local/script_data"
[[ $? -ne 0 ]] && exit 1
