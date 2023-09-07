#!/bin/bash
#
# gnome.sh - part of the Arch-Setup project
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


echo -e '\n#Opens new tabs in the current working directory' >> ~/.bashrc
echo 'source /etc/profile.d/vte.sh' >> ~/.bashrc

# ----------- Configure system settings -----------

# Set the color theme to dark for the system
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

python3 NonUserRunnable/set_keyboard_shortcuts.py

# ----------- Configure terminal settings -----------

# Get the default terminal profile
terminal_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')

# Set the font-name and font-size
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ font 'Source Code Pro 14'
# Set the terminal size
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ default-size-columns 88
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ default-size-rows 20

# Turn off the terminal bell
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ audible-bell false

#
# Set the shortcuts
#
# Switch to next tab
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ next-tab '<Control>Return'
# Switch to previous tab
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ prev-tab '<Control>BackSpace'
