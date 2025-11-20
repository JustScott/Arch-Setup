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

#
# Installs flatpak for running steam games, along with any other packages
#  your system may need for gaming. Assumes a dual user system, in which
#  you have a user in the wheel group for installing system wide packages,
#  and a non sudo/wheel user for installing flatpaks locally.
#

if [[ $(basename $PWD) != "Arch-Setup" ]]
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup base directory"
    exit 1
fi

source ./shared_lib

AUR_PACKAGES=( flatpak btop rocm-smi-lib ) 
FLATPAK_PACKAGES=( com.github.tchx84.Flatseal com.valvesoftware.Steam )

if groups | grep -E "(sudo|wheel)" &>/dev/null
then
    sudo -v
    if ! which yay &>/dev/null
    then
        bash aur.sh
    fi
    if ! yay -Q ${AUR_PACKAGES[@]} &>/dev/null; then
        yes | yay -Sy --noconfirm ${AUR_PACKAGES[@]} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Download gaming related packages and Flatpak for installing steam"
        [[ $? -ne 0 ]] && exit 1
    else
        printf "\r\e[34m[Skipping]\e[0m %s\n" "Gaming related packages and Flatpak already installed"
    fi
else
    if { which flatpak || type flatpak; } &>/dev/null
    then
        # Add flathub remote for the user
        flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Add remote source 'flathub' to flatpak"
        [[ $? -ne 0 ]] && exit 1

        flatpak install --noninteractive --or-update --user -y ${FLATPAK_PACKAGES[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Install or update GUI apps with flatpak"  
        [[ $? -ne 0 ]] && exit 1

        flatpak override --user --device=dri com.valvesoftware.Steam
        task_output $! "$STDERR_LOG_PATH" "Enable GPU acceleration for Steam"  
        [[ $? -ne 0 ]] && exit 1

        {
            for flatpak in ${FLATPAK_PACKAGES[@]}    
            do    
                flatpak_name=$(echo $flatpak | awk -F'.' '{print $NF}' | tr '[:upper:]' '[:lower:]')    
                 
                if ! cat $HOME/.bashrc | grep "alias $flatpak_name=\"\$HOME/.local/share/flatpak/exports/bin/$flatpak\"" &>/dev/null    
                then
                    echo "alias $flatpak_name=\"\$HOME/.local/share/flatpak/exports/bin/$flatpak\"" >> $HOME/.bashrc    
                fi
            done
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Add an alias for each flatpak app to .bashrc"
        [[ $? -ne 0 ]] && exit 1
    else
        printf "\r\e[31m[Error]\e[0m %s\n" \
            "Must run script with sudo priveleges first to install Flatpak system wide"
    fi
fi


# Nvidia laptops
#AUR_PACKAGES+=(optimus-manager-git libgdm-prime gdm-prime)
#optimus-manager --switch nvidia --noconfirm

# Mod manager for lethal company
#AUR_PACKAGES+=( r2modman-bin )
#
# Edit /usr/share/applications/r2modman.desktop, adding --no-sandbox to
#  the exec command, before the %U
#

# system wide access to Flatpaks
#sudo ln -s /var/lib/flatpak/exports/bin/com.github.tchx84.Flatseal /usr/local/bin/flatseal
#sudo ln -s /var/lib/flatpak/exports/bin/com.valvesoftware.steam /usr/local/bin/steam

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
