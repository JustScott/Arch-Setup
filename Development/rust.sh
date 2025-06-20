#!/bin/bash
#
# rust.sh - part of the Arch-Setup project
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

if [[ $(basename $PWD) != "Development" ]]
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup/Development directory"
    exit 1
fi

source ../shared_lib

sudo -v

packages=(rustup)

if ! pacman -Q ${packages[@]} &>/dev/null; then
    sudo pacman -Sy ${packages[@]} --noconfirm >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Download and install rust development packages"
    [[ $? -ne 0 ]] && exit 1
fi

rustup default stable >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Use Rust stable branch"
[[ $? -ne 0 ]] && exit 1

if ! cat $HOME/.bashrc | grep "export PATH=\"\$PATH:\$HOME/.cargo/bin\"" &>/dev/null
then
    echo -e "\nexport PATH=\"\$PATH:\$HOME/.cargo/bin\"" >> $HOME/.bashrc
    task_output $! "$STDERR_LOG_PATH" "Add cargo binaries to PATH"
    [[ $? -ne 0 ]] && exit 1
fi

