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


echo -e "\n#Opens new tabs in the current working directory" >> ~/.bashrc
echo "source /etc/profile.d/vte.sh" >> ~/.bashrc

# ----------- Configure system settings -----------

# Set the color theme to dark for the system
ACTION="Set Desktop Color Theme to Dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" &>/dev/null \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION"
    

# ----------- Configure terminal settings -----------

# Get the default terminal profile
terminal_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')

[[ -n $terminal_profile ]] && {
    # Set the font-name and font-size
    ACTION="Set Font Name & Size"
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ font "Source Code Pro 14" &>/dev/null \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION"

    ACTION="Set Terminal Size in Columns"
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ default-size-columns 88 &>/dev/null \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION"

    ACTION="Set Terminal Size in Rows"
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ default-size-rows 20 &>/dev/null \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION"

    ACTION="Turn off the Terminal Bell"
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ audible-bell false &>/dev/null \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION"
} || echo "[FAIL] Failed to get terminal profile... skipping related commands"

# ----------- Set Shortcuts & Keybindings -----------

ACTION="Set Desktop Shortcuts"
python3 DoNotRun/set_keyboard_shortcuts.py &>/dev/null \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION"

ACTION="Set Keybind: Switch to the Next Terminal Tab = <Control>Return"
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ next-tab '<Control>Return' &>/dev/null \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION"
# Switch to previous tab
ACTION="Set Keybind: Switch to the Previous Terminal Tab = <Control>BackSpace"
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ prev-tab '<Control>BackSpace' &>/dev/null \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION"
