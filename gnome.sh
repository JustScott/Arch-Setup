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

set_keybindings() {
    declare -A shortcut_keybinds=(
        ["Terminal"]="<Ctrl><Alt>t"
        ["Browser"]="<Ctrl><Shift>b"
        ["AUR"]="<Ctrl><Alt>a"
    )

    declare -A shortcut_commands=(
        ["Terminal"]="gnome-terminal"
        ["Browser"]="xdg-open https://":
        ["AUR"]="xdg-open https://wiki.archlinux.org"
    )

    keybind_locations="["
    for ((count=0;count<${#shortcut_keybinds[@]};count++)); do
        keybind_locations+="'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$count/'"
        [[ $count == $((${#shortcut_keybinds[@]}-1)) ]] && keybind_locations+="]" || keybind_locations+=", "
    done

    ACTION="Set Keybind locations"
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$keybind_locations" >/dev/null 2>>~/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"

    keybind_index=0
    for name in "${!shortcut_keybinds[@]}"; do
        binding="${shortcut_keybinds[$name]}"
        command="${shortcut_commands[$name]}"

        ACTION="Set Desktop Shortcut for '$name'"
        gsettings set \
            org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$keybind_index/ binding "$binding" \
            >/dev/null 2>>~/archsetuperrors.log \
        && gsettings set \
            org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$keybind_index/ command "$command" \
            >/dev/null 2>>~/archsetuperrors.log \
        && gsettings set \
            org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$keybind_index/ name "$name" \
            >/dev/null 2>>~/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"
        
        ((keybind_index++))
    done
}


# ----------- Configure terminal settings -----------

sudo pacman -Sy --noconfirm \
    gnome-control-center gnome-backgrounds gnome-terminal \
    gnome-keyring gnome-logs gnome-settings-daemon \
    gnome-calculator gnome-software gvfs malcontent mutter \
    gdm nautilus xdg-user-dirs-gtk xorg


# ----------- Configure terminal settings -----------

echo -e "\n#Opens new tabs in the current working directory" >> ~/.bashrc
echo "source /etc/profile.d/vte.sh" >> ~/.bashrc

# Set the color theme to dark for the system
ACTION="Set Desktop Color Theme to Dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" >/dev/null 2>>~/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"

# Get the default terminal profile
terminal_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')

[[ -n $terminal_profile ]] && {
    # Set the font-name and font-size
    ACTION="Set Font Name & Size"
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ font "Source Code Pro 14" >/dev/null 2>>~/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"

    ACTION="Set Terminal Size in Columns"
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ default-size-columns 88 >/dev/null 2>>~/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"

    ACTION="Set Terminal Size in Rows"
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ default-size-rows 20 >/dev/null 2>>~/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"

    ACTION="Turn off the Terminal Bell"
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ audible-bell false >/dev/null 2>>~/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"
} || echo "[FAIL] Failed to get terminal profile... skipping related commands"

# ----------- Set Shortcuts & Keybindings -----------

set_keybindings

ACTION="Set Keybind: Switch to the Next Terminal Tab = <Control>Return"
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ next-tab '<Control>Return' >/dev/null 2>>~/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"
# Switch to previous tab
ACTION="Set Keybind: Switch to the Previous Terminal Tab = <Control>BackSpace"
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ prev-tab '<Control>BackSpace' >/dev/null 2>>~/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"


# ----------- Start the gnome desktop environment -----------

sudo systemctl enable --now gdm

