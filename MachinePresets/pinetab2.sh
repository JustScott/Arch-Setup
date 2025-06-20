#!/bin/bash
#
# pinetab2.sh - part of the Arch-Setup project
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

if [[ $(basename $PWD) != "MachinePresets" ]]
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup/MachinePresets directory"
    exit 1
fi

source ../shared_lib

sudo -v

bash base.sh

get_name() {
    while : 
    do
        read -p 'Enter Name: ' name
        read -p 'Verify Name: ' name_verify

        if [[ -z "$name" ]]
        then
            clear
            echo -e " - Name Can't Be Empty - \n"
            continue
        fi

        if [[ $name == $name_verify ]]
        then
            break
        else 
            clear
            echo -e " - Names Don't Match - \n"
        fi
    done
}

get_user_password() {
    echo -e "\n - Set Password for '$1' - "
    while :
    do
        read -s -p 'Set Password: ' user_password
        read -s -p $'\nverify Password: ' user_password_verify

        if [[ $user_password == $user_password_verify ]]
        then
            echo -e "\n\n - Set password for $1! - \n"
            break
        else
            clear
            echo -e " - Passwords Don't Match - \n"
        fi
    done
}

echo -e "\n  Choose the username for your new user\n"
get_name
sudo useradd -m -G network,rfkill,video,audio,wheel $name
get_user_password $name
sudo bash -c "echo "$name:$user_password" | chpasswd"

unset user_password user_password_verify

sudo chown $name:$name /tmp/archsetuperrors.log

sudo -i -u $name bash << EOF
    cd \$HOME
    mkdir -p Git/Hub/ArchProjects
    cd Git/Hub/ArchProjects

    [[ -d "Arch-Setup" ]] \
        || git clone https://www.github.com/JustScott/Arch-Setup
    [[ -d "Arch-Configurations" ]] \
        || git clone https://www.github.com/JustScott/Arch-Configurations

    cd Arch-Setup/MachinePresets
    bash host.sh
EOF

su $name
