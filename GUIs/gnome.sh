#!/bin/bash
#
# gnome.sh - part of the Arch-Setup project
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

if [[ $(basename $PWD) != "GUIs" ]]
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup/GUIs directory"
    exit 1
fi

source ../shared_lib

sudo -v

set_keybindings() {
    declare -A shortcut_keybinds=(
        ["Terminal"]="<Shift><Alt><Return>"
        ["Browser"]="<Alt>b"
    )

    declare -A shortcut_commands=(
        ["Terminal"]="foot"
        ["Browser"]="xdg-open https://":
    )

    keybind_locations="["
    for ((count=0;count<${#shortcut_keybinds[@]};count++)); do
        keybind_locations+="'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$count/'"
        [[ $count == $((${#shortcut_keybinds[@]}-1)) ]] && keybind_locations+="]" || keybind_locations+=", "
    done

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
        "$keybind_locations" >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Set Keybinds Location"
    [[ $? -ne 0 ]] && exit 1

    keybind_index=0
    for name in "${!shortcut_keybinds[@]}"; do
        binding="${shortcut_keybinds[$name]}"
        command="${shortcut_commands[$name]}"

        gsettings set \
            org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$keybind_index/ binding "$binding" >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Set Desktop Shortcut for '$name'"
        [[ $? -ne 0 ]] && exit 1

        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$keybind_index/ name "$name" >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Set Keybind: '$binding'"
        [[ $? -ne 0 ]] && exit 1

        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$keybind_index/ command "$command" >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Set Keybind Command: '$command'"
        [[ $? -ne 0 ]] && exit 1
        
        ((keybind_index++))
    done
}


# ----------- Configure terminal settings -----------

packages=(
    gnome-control-center gnome-backgrounds gnome-terminal \
    gnome-keyring gnome-settings-daemon gnome-calculator \
    flatpak discover gnome-color-manager gvfs mutter \
    gdm foot nautilus xdg-user-dirs-gtk xorg evince \
)

if ! pacman -Q ${packages[@]} &>/dev/null; then
    yes | sudo pacman -Sy --noconfirm ${packages[@]} \
        >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" \
        "Download and install gnome packages with pacman (this may take awhile)"
    [[ $? -ne 0 ]] && exit 1
fi


# ----------- Configure terminal settings -----------

if ! grep "source /etc/profile.d/vte.sh" $HOME/.bashrc &>/dev/null
then
    echo -e "\n#Opens new tabs in the current working directory" >> ~/.bashrc
    echo "source /etc/profile.d/vte.sh" >> ~/.bashrc
fi

gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" \
    >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Set Desktop Color Theme to Dark"
[[ $? -ne 0 ]] && exit 1

terminal_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')

if [[ -n $terminal_profile ]]
then
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ \
        font "Source Code Pro 14" >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Set Font Name & Size"
    [[ $? -ne 0 ]] && exit 1

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ \
        default-size-columns 88 >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Set Terminal Size in Columns"
    [[ $? -ne 0 ]] && exit 1

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ \
        default-size-rows 20 >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Set Terminal Size in Rows"
    [[ $? -ne 0 ]] && exit 1

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$terminal_profile"/ \
        audible-bell false >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Turn off the Terminal Bell"
    [[ $? -ne 0 ]] && exit 1
else
    printf "\e[31m%s\e[0m\n" \
        "[Error] Failed to get terminal profile... skipping related commands"
fi

# ----------- Set Shortcuts & Keybindings -----------

set_keybindings

gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ \
    next-tab '<Control>Return' >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" \
    "Set Keybind: Switch to the Next Terminal Tab = <Control>Return"
[[ $? -ne 0 ]] && exit 1

gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ \
    prev-tab '<Control>BackSpace' >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" \
    "Set Keybind: Switch to the Previous Terminal Tab = <Control>BackSpace"
[[ $? -ne 0 ]] && exit 1


# ----------- Start the gnome desktop environment -----------

cd $HOME
