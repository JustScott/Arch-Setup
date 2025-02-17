#!/bin/bash
#
# manjaro-gaming.sh - part of the Arch-Setup project
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

if ! [[ $(basename "$PWD") == "MachinePresets" ]]
then
    echo "Must be in the Arch-Setup/MachinePresets directory to run this script!"
    exit 1
fi

cd ..
bash media.sh
bash general-scripts.sh
cd MachinePresets
bash base.sh


VIRTUAL_MACHINES_PWD=$PWD

if ! { which yay || type yay; } &>/dev/null
then
    ACTION="Clone, compile, and install yay from the AUR (this may take a while)"
    echo -n "...$ACTION..."
    cd # pwd -> $HOME
    if git clone https://aur.archlinux.org/yay.git >/dev/null 2>>/tmp/archsetuperrors.log
    then
        {
            cd yay >/dev/null 2>>/tmp/archsetuperrors.log
            makepkg -si PKGBUILD --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log
            cd $VIRTUAL_MACHINES_PWD
        } >/dev/null 2>>/tmp/archsetuperrors.log \
            && echo "[SUCCESS]" \
            || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit; }
    else
        echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"
        exit 1
    fi
fi

sudo pacman -Sy --noconfirm base-devel vim neovim lf flatpak 

yay -Sy --noconfirm optimus-manager-git #r2modman-bin 

clear

echo -e "\n\n -- Answer 'y' when asked to confirm replacing gdm related packages -- \n\n"


yay -Sy libgdm-prime gdm-prime

# Would be nice if this would automatically switch over 
#echo 'optimus-manager --switch nvidia --noconfirm' >> ~/.bash_profile
echo 'export EDITOR=nvim' >> ~/.bashrc


flatpak install com.bitwarden.desktop \
    io.gitlab.librewolf-community \
    com.github.tchx84.Flatseal \
    com.valvesoftware.Steam \
    com.play0ad.zeroad -y

sudo ln -s /var/lib/flatpak/exports/bin/com.bitwarden.desktop /usr/local/bin/bitwarden
sudo ln -s /var/lib/flatpak/exports/bin/io.gitlab.librewolf-community /usr/local/bin/librewolf
sudo ln -s /var/lib/flatpak/exports/bin/com.github.tchx84.Flatseal /usr/local/bin/flatseal
sudo ln -s /var/lib/flatpak/exports/bin/com.valvesoftware.steam /usr/local/bin/steam
sudo ln -s /var/lib/flatpak/exports/bin/com.play0ad.zeroad /usr/local/bin/zeroad

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
