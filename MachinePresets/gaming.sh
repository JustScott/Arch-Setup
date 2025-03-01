#!/bin/bash
#
# gaming.sh - part of the Arch-Setup project
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

bash base.sh
cd ..
bash aur.sh
bash media.sh
bash general-scripts.sh
cd MachinePresets

VIRTUAL_MACHINES_PWD=$PWD

packages=( flatpak ) 

# Nvidia laptops
#packages+=(optimus-manager-git libgdm-prime gdm-prime)

# Mod manager for lethal company
#packages+=( r2modman-bin )

if ! yay -Q ${packages[@]} &>/dev/null; then
    yes | yay -Sy --noconfirm ${packages[@]} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Download gaming related packages and flatpak for installing steam"
    [[ $? -ne 0 ]] && exit 1
fi

# Nvidia laptops (doesn't work last I checked)
#echo 'optimus-manager --switch nvidia --noconfirm' >> ~/.bash_profile

grep "export EDITOR=nvim" $HOME/.bash_profile &>/dev/null \
    || echo -e "\nexport EDITOR=nvim" >> $HOME/.bash_profile

# Optional
#    com.bitwarden.desktop \
#    io.gitlab.librewolf-community \
#    com.play0ad.zeroad
flatpak install -y com.github.tchx84.Flatseal com.valvesoftware.Steam \
    >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Install some GUI apps with flatpak"
[[ $? -ne 0 ]] && exit 1

#    sudo ln -s /var/lib/flatpak/exports/bin/com.bitwarden.desktop /usr/local/bin/bitwarden
#    sudo ln -s /var/lib/flatpak/exports/bin/io.gitlab.librewolf-community /usr/local/bin/librewolf
#    sudo ln -s /var/lib/flatpak/exports/bin/com.play0ad.zeroad /usr/local/bin/zeroad
{
    sudo ln -s /var/lib/flatpak/exports/bin/com.github.tchx84.Flatseal /usr/local/bin/flatseal
    sudo ln -s /var/lib/flatpak/exports/bin/com.valvesoftware.steam /usr/local/bin/steam
} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Add GUI app to PATH"
[[ $? -ne 0 ]] && exit 1

#
# Edit /usr/share/applications/r2modman.desktop, adding --no-sandbox to
#  the exec command, before the %U
#
#

# Might just leave this here for the user to run manually
#  so they can have exact swapfile sizes
#
#sudo fallocate -l 16G /swapfile
#sudo chmod 600 /swapfile
#sudo mkswap /swapfile
#sudo echo '/swapfile none swap 0 0' >> /etc/fstab
#sudo mkinitcpio --allpresets
#sudo grub-install --options
#sudo grub-mkconfig -o /etc/grub/grub.cfg 
