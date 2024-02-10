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


# Call other needed scripts
bash gnome.sh
bash media.sh
bash user.sh
bash secure.sh

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..

sudo pacman -Sy base-devel vim neovim lf flatpak --noconfirm

yay -Sy optimus-manager-git r2modman-bin --noconfirm

clear

echo -e "\n\n -- Answer 'y' when asked to confirm replacing gdm related packages -- \n\n"

yay -Sy libgdm-prime gdm-prime


echo 'optimus-manager --switch nvidia --noconfirm' >> ~/.bash_profile
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

