#!/bin/bash
#
# manjaro-gaming.sh - part of the Arch-Setup project
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

packages=(optimus-manager-git flatpak libgdm-prime gdm-prime) # r2modman-bin

if ! pacman -Q ${packages[@]} &>/dev/null; then
    #echo -e "\n\n -- Answer 'y' when asked to confirm replacing gdm related packages -- \n\n"
    yes | yay -Sy --noconfirm ${packages[@]} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Download and install pipewire audio packages with pacman"
    [[ $? -ne 0 ]] && exit 1
fi

# Would be nice if this would automatically switch over 
#echo 'optimus-manager --switch nvidia --noconfirm' >> ~/.bash_profile
grep "export EDITOR=nvim" $HOME/.bash_profile &>/dev/null \
    || echo -e "\nexport EDITOR=nvim" >> $HOME/.bash_profile

flatpak install com.bitwarden.desktop \
    io.gitlab.librewolf-community \
    com.github.tchx84.Flatseal \
    com.valvesoftware.Steam \
    com.play0ad.zeroad -y >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Install some GUI apps with flatpak"
[[ $? -ne 0 ]] && exit 1

{
    sudo ln -s /var/lib/flatpak/exports/bin/com.bitwarden.desktop /usr/local/bin/bitwarden
    sudo ln -s /var/lib/flatpak/exports/bin/io.gitlab.librewolf-community /usr/local/bin/librewolf
    sudo ln -s /var/lib/flatpak/exports/bin/com.github.tchx84.Flatseal /usr/local/bin/flatseal
    sudo ln -s /var/lib/flatpak/exports/bin/com.valvesoftware.steam /usr/local/bin/steam
    sudo ln -s /var/lib/flatpak/exports/bin/com.play0ad.zeroad /usr/local/bin/zeroad
} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Download and install pipewire audio packages with pacman"
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
