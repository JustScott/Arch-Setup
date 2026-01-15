#!/bin/bash
#
# setup_installation_library.sh - part of the Arch-Setup project
# Copyright (C) 2025, JustScott, development@justscott.me
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

PRETTY_OUTPUT_LIBRARY=pretty_output_library.sh

SSH_CONFIG_FILE_PATH="/etc/ssh/sshd_config.d/99‑disable‑root.conf"

enforce_library_files_exist() {
    if ! [[ -f "./$PRETTY_OUTPUT_LIBRARY" ]]
    then
        echo -e "\n - Missing pretty output script. Cannot Proceed - \n"
        exit 4
    fi
}

enforce_library_files_exist

source ./$PRETTY_OUTPUT_LIBRARY


setup_user_scripts()
{
    if ! [[ -d "$arch_setup_directory" ]]
    then
        printf "\n\e[31m%s\n%s\n%s\e[0m\n" \
            "[!] '\$arch_setup_directory' variable not set, or not set to" \
            "    the correct directory path. Either way, \`cd\` into the" \
            "    '$PROJECT_NAME' directory and run \`$SCRIPT_NAME add-to-path\`."
        exit $4
    fi

    scripts_dir="$arch_setup_directory/DoNotRun/scripts/user_scripts"
    bashrc_line="export PATH=\"\$PATH:$scripts_dir\""

    if ! grep "$bashrc_line" $HOME/.bashrc &>/dev/null
    then
        echo -e "\n$bashrc_line" >> $HOME/.bashrc 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Add the user scripts directory to \$PATH in .bashrc"
        [[ $? -ne 0 ]] && return 1
    fi

    return 0
}
remove_setup_user_scripts()
{
    if sed -i \
        '/export PATH=".*Arch-Setup\/DoNotRun\/scripts\/user_scripts"/d' \
        $HOME/.bashrc
    then
        printf "\n\e[32m%s\e[0m\n" "Remove user_scripts from path"
    else
        printf "\n\e[31m%s\e[0m\n" \
            "[!] Cannot remove user scripts from \$PATH... this shouldn't happen"
    fi

    return 0
}


setup_qemu() 
{
    packages=(
        gnome-boxes virt-manager virt-viewer \
        qemu-emulators-full spice-vdagent swtpm \
    )

    if ! pacman -Q ${packages[@]} &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Sy --noconfirm ${packages[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Install qemu packages"
        [[ $? -ne 0 ]] && return 1
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" \
            "Qemu packages already installed"
    fi

    # Allows currently plugged in USB devices, so doesn't really make
    # sense to be in the setup
    #sudo chmod g+rwx -R /dev/bus/usb

    CURRENT_USER=$USER

    {
        if ! cat /etc/libvirt/libvirtd.conf \
            | grep 'unix_sock_group = libvirt' &>/dev/null
        then
            sudo bash -c 'echo -e "\nunix_sock_group = libvirt" >> /etc/libvirt/libvirtd.conf'
        fi
        if ! cat /etc/libvirt/libvirtd.conf \
            | grep 'unix_sock_rw_perms = 0770' &>/dev/null
        then
            sudo bash -c 'echo "unix_sock_rw_perms = 0770" >> /etc/libvirt/libvirtd.conf'
        fi
        if ! cat /etc/libvirt/qemu.conf | grep "group=$CURRENT_USER" &>/dev/null
        then
            sudo bash -c "echo 'group=$CURRENT_USER' >> /etc/libvirt/qemu.conf"
        fi
    } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Alter config files"
    [[ $? -ne 0 ]] && return 1

    if ! groups | grep "libvirt" &>/dev/null
    then
        sudo usermod -aG libvirt $CURRENT_USER \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Add '$CURRENT_USER' to 'libvirt' group"
        [[ $? -ne 0 ]] && return 1
    fi

    return 0
}
remove_setup_qemu() 
{
    packages=(
        gnome-boxes virt-manager virt-viewer \
        qemu-emulators-full spice-vdagent swtpm \
    )

    for package in ${packages[@]}
    do
        if pacman -Q $package &>/dev/null
        then
            sudo -v
            yes | sudo pacman -Rs --noconfirm $package \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Uninstalling package: $package"
            [[ $? -ne 0 ]] && return 1
        fi
    done

    if ! groups | grep "libvirt" &>/dev/null
    then
        sudo gpasswd -d $CURRENT_USER libvirt \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Remove '$CURRENT_USER' from the 'libvirt' group"
        [[ $? -ne 0 ]] && return 1
    fi

    return 0
}


setup_security()
{
    sudo -v

    if grep -e "^# deny = " -e "^deny = " /etc/security/faillock.conf &>/dev/null
    then
        sudo sed -i \
            -e '/^# deny =/c\deny = 6' \
            -e '/^deny =/c\deny = 6' \
            /etc/security/faillock.conf &>/dev/null \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Change max login attempts before lock out to 6 (3 isn't enough)"
        [[ $? -ne 0 ]] && return 1
    fi

    sudo passwd --lock root >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Disable root login"
    [[ $? -ne 0 ]] && return 1

    if ! [[ -f "$SSH_CONFIG_FILE_PATH" ]]
    then
        sudo bash -c \
            "echo 'PermitRootLogin no' >> "$SSH_CONFIG_FILE_PATH"" \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Add rule to disable root login over ssh"
        [[ $? -ne 0 ]] && return 1

        if systemctl is-active sshd &>/dev/null
        then
            sudo systemctl reload sshd \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Reload the ssh daemon"
            [[ $? -ne 0 ]] && return 1
        fi
    fi

    return 0
}
remove_setup_security()
{
    sudo -v

    if grep "^deny = 6" /etc/security/faillock.conf &>/dev/null
    then
        sudo sed -i '/^deny = 6/c\deny = 3' \
            /etc/security/faillock.conf &>/dev/null \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Change max login attempts before lock out back to 3"
        [[ $? -ne 0 ]] && return 1
    fi

    sudo passwd --unlock root >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Enable root login"
    [[ $? -ne 0 ]] && return 1

    if [[ -f "$SSH_CONFIG_FILE_PATH" ]]
    then
        sudo rm $SSH_CONFIG_FILE_PATH &>/dev/null
        task_output $! "$STDERR_LOG_PATH" \
            "Remove rule against root login over ssh"
        [[ $? -ne 0 ]] && return 1

        if systemctl is-active sshd &>/dev/null
        then
            sudo systemctl reload sshd \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Reload the ssh daemon"
            [[ $? -ne 0 ]] && return 1
        fi
    fi

    return 0
}


setup_audio()
{
    packages=(
        pipewire pipewire-alsa pipewire-audio pipewire-jack \
        pipewire-pulse pavucontrol pamixer \
    )

    if pacman -Q pulseaudio &>/dev/null; then
        if systemctl --user is-active --quiet pulseaudio &>/dev/null
        then
            systemctl --user disable --now pulseaudio &>/dev/null
            task_output $! "$STDERR_LOG_PATH" \
                "Disable and stop pulseaudio service"
        fi

        sudo -v
        yes | sudo pacman -R pulseaudio \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Remove pulseaudio"
        [[ $? -ne 0 ]] && return 1
    fi

    if ! pacman -Q ${packages[@]} &>/dev/null; then
        sudo -v
        yes | sudo pacman -Sy ${packages[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Download and install pipewire audio packages with pacman"
        [[ $? -ne 0 ]] && return 1
    fi

    if ! systemctl --user is-enabled pipewire &>/dev/null
    then
        systemctl --user enable pipewire \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Enable the pipewire services"
        [[ $? -ne 0 ]] && return 1
    fi

    if ! systemctl --user is-active pipewire &>/dev/null
    then
        systemctl --user start pipewire \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Start pipewire services"
        [[ $? -ne 0 ]] && return 1
    fi

    if ! systemctl --user is-enabled pipewire-pulse &>/dev/null
    then
        systemctl --user enable pipewire-pulse \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Enable the pipewire-pulse services"
        [[ $? -ne 0 ]] && return 1
    fi

    if ! systemctl --user is-active pipewire-pulse &>/dev/null
    then
        systemctl --user start pipewire-pulse \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Start the pipewire-pulse services"
        [[ $? -ne 0 ]] && return 1
    fi

    return 0
}
remove_setup_audio()
{
    packages=(
        pipewire pipewire-alsa pipewire-audio pipewire-jack \
        pipewire-pulse pavucontrol pamixer \
    )

    if pacman -Q pulseaudio &>/dev/null; then
        if systemctl --user is-active --quiet pulseaudio &>/dev/null
        then
            systemctl --user disable --now pulseaudio &>/dev/null
            task_output $! "$STDERR_LOG_PATH" \
                "Disable and stop pulseaudio service"
        fi

        sudo -v
        yes | sudo pacman -Rs pulseaudio \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Remove pulseaudio"
        [[ $? -ne 0 ]] && return 1
    fi

    for package in ${packages[@]}
    do
        if pacman -Q $package &>/dev/null
        then
            sudo -v
            yes | sudo pacman -Rs --noconfirm $package \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Uninstalling package: $package"
            [[ $? -ne 0 ]] && return 1
        fi
    done

    if systemctl --user is-enabled pipewire &>/dev/null
    then
        systemctl --user disable pipewire \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Disable the pipewire services"
        [[ $? -ne 0 ]] && return 1
    fi

    if systemctl --user is-active pipewire &>/dev/null
    then
        systemctl --user stop pipewire \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Stop pipewire services"
        [[ $? -ne 0 ]] && return 1
    fi

    if systemctl --user is-enabled pipewire-pulse &>/dev/null
    then
        systemctl --user disable pipewire-pulse \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Disable the pipewire-pulse services"
        [[ $? -ne 0 ]] && return 1
    fi

    if systemctl --user is-active pipewire-pulse &>/dev/null
    then
        systemctl --user stop pipewire-pulse \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Stop the pipewire-pulse services"
        [[ $? -ne 0 ]] && return 1
    fi

    return 0
}


setup_bluetooth()
{
    packages=(bluez bluez-utils)

    if ! pacman -Q ${packages[@]} &>/dev/null; then
        sudo -v
        yes | sudo pacman -Sy --noconfirm ${packages[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Download and install bluetooth packages with pacman"
        [[ $? -ne 0 ]] && return 1
    fi

    if ! systemctl is-enabled bluetooth &>/dev/null
    then
        sudo -v
        sudo systemctl enable bluetooth \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Enable bluetooth"
        [[ $? -ne 0 ]] && return 1
    fi

    if ! systemctl is-active bluetooth &>/dev/null
    then
        sudo -v
        sudo systemctl start bluetooth \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Start bluetooth service"
        [[ $? -ne 0 ]] && return 1
    fi

    if rfkill list bluetooth | grep "Soft blocked: yes" &>/dev/null
    then
        sudo -v
        sudo rfkill unblock bluetooth >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Remove bluetooth soft block"
        [[ $? -ne 0 ]] && return 1
    fi

    return 0
}
remove_setup_bluetooth()
{
    packages=(bluez bluez-utils)

    if systemctl is-active bluetooth &>/dev/null
    then
        sudo -v
        sudo systemctl stop bluetooth \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Stop bluetooth service"
        [[ $? -ne 0 ]] && return 1
    fi

    if systemctl is-enabled bluetooth &>/dev/null
    then
        sudo -v
        sudo systemctl disable bluetooth \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Disable bluetooth service"
        [[ $? -ne 0 ]] && return 1
    fi

    for package in ${packages[@]}
    do
        if pacman -Q $package &>/dev/null
        then
            sudo -v
            yes | sudo pacman -Rs --noconfirm $package \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Uninstalling package: $package"
            [[ $? -ne 0 ]] && return 1
        fi
    done

    return 0
}


setup_media()
{
    packages=(ytfzf fzf mpv yt-dlp)

    # Specifically for the yt-x script
    packages+=(jq curl ffmpeg)

    if ! pacman -Q ${packages[@]} &>/dev/null; then
        sudo -v
        yes | sudo pacman -Sy --noconfirm ${packages[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Download and install media packages with pacman"
        [[ $? -ne 0 ]] && return 1
    fi

    return 0
}
remove_setup_media()
{
    packages=(ytfzf fzf mpv yt-dlp)

    # Specifically for the yt-x script
    packages+=(jq curl ffmpeg)

    for package in ${packages[@]}
    do
        if pacman -Q $package &>/dev/null
        then
            sudo -v
            yes | sudo pacman -Rs --noconfirm $package \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Uninstalling package: $package"
            [[ $? -ne 0 ]] && return 1
        fi
    done

    return 0
}


setup_gaming()
{
    REQUIRED_PACKAGES=( flatpak )
    PACKAGES=( btop rocm-smi-lib )
    PACKAGES+=(${REQUIRED_PACKAGES[@]})
    FLATPAK_PACKAGES=( com.github.tchx84.Flatseal com.valvesoftware.Steam )

    if groups | grep -E "(sudo|wheel)" &>/dev/null
    then
        sudo -v
        if ! pacman -Q ${PACKAGES[@]} &>/dev/null; then
            yes | sudo pacman -Sy --noconfirm ${PACKAGES[@]} \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Download gaming related packages"
            [[ $? -ne 0 ]] && return 1
        else
            printf "\r\e[34m[Skipping]\e[0m %s\n" \
                "Gaming related packages and Flatpak already installed"
        fi
    fi
    if pacman -Q ${REQUIRED_PACKAGES[@]} &>/dev/null
    then
        flatpak remote-add --if-not-exists --user flathub \
            https://flathub.org/repo/flathub.flatpakrepo \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Add remote source 'flathub' to flatpak"
        [[ $? -ne 0 ]] && return 1

        flatpak install --noninteractive --or-update \
            --user -y ${FLATPAK_PACKAGES[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Install or update GUI apps with flatpak"
        [[ $? -ne 0 ]] && return 1

        flatpak override --user --device=dri com.valvesoftware.Steam
        task_output $! "$STDERR_LOG_PATH" \
            "Enable GPU acceleration for Steam"
        [[ $? -ne 0 ]] && return 1

        {
            for flatpak in ${FLATPAK_PACKAGES[@]} 
            do 
                flatpak_name=$(echo $flatpak | awk -F'.' '{print $NF}' \
                    | tr '[:upper:]' '[:lower:]')

                bashrc_line="alias $flatpak_name=\"\$HOME/.local/share/flatpak/exports/bin/$flatpak\""
 
                if ! grep "$bashrc_line" $HOME/.bashrc &>/dev/null 
                then
                    echo "$bashrc_line" >> $HOME/.bashrc
                fi
            done
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Add an alias for each flatpak app to .bashrc"
        [[ $? -ne 0 ]] && return 1
    else
        printf "\r\e[31m%s\e[0m\n" \
            "[!] Must install flatpak with pacman"
        return 1
    fi

    return 0
}
remove_setup_gaming()
{
    # Not removing flatpak as it could be used by the user
    PACKAGES=( btop rocm-smi-lib )

    for package in ${packages[@]}
    do
        if pacman -Q $package &>/dev/null
        then
            sudo -v
            yes | sudo pacman -Rs --noconfirm $package \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Uninstalling package: $package"
            [[ $? -ne 0 ]] && return 1
        fi
    done

    return 0
}


setup_embedded_rust()
{
    if ! command -v cargo &>/dev/null
    then
        printf "\n\e[31m%s\e[0m\n" \
            "[!] cargo not installed, try running \`arch install rust\` first"
        return 1
    fi

    cargo_packages=(probe-rs-tools elf2uf2-rs)

    for cargo_package in ${cargo_packages[@]}
    do
        cargo install $cargo_package \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Download and compile: '$cargo_package' with cargo"
        [[ $? -ne 0 ]] && return 1
    done

    packages=(openocd)

    if ! pacman -Q ${packages[@]} &>/dev/null; then
        sudo -v
        yes | sudo pacman -Sy ${packages[@]} --noconfirm \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Install debugging package(s) with pacman"
        [[ $? -ne 0 ]] && return 1
    fi

    return 0
}
remove_setup_embedded_rust()
{
    cargo_packages=(probe-rs-tools elf2uf2-rs)

    installed_cargo_packages="$(\
        cargo install --list | grep '^[a-z]' | awk '{print $1}'\
    )"

    for cargo_package in ${cargo_packages[@]}
    do
        if echo "$installed_cargo_packages" \
            | grep "^$cargo_package$" &>/dev/null
        then
            cargo uninstall ${cargo_package[@]} \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Uninstall cargo package: '$cargo_package'"
            [[ $? -ne 0 ]] && return 1
        fi
    done

    packages=(openocd)

    for package in ${packages[@]}
    do
        if pacman -Q $package &>/dev/null
        then
            sudo -v
            yes | sudo pacman -Rs --noconfirm $package \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Uninstalling package: $package"
            [[ $? -ne 0 ]] && return 1
        fi
    done

    return 0
}


setup_rust_dioxus()
{
    if ! command -v cargo &>/dev/null
    then
        printf "\n\e[31m%s\e[0m\n" \
            "[!] cargo not installed, try running \`arch install rust\` first"
        return 1
    fi

    pacman_packages=(\
        webkit2gtk-4.1 base-devel curl wget file \
        openssl appmenu-gtk-module libappindicator-gtk3 \
        librsvg xdotool \
    )

    cargo_packages=(dioxus-cli)

    if ! pacman -Q ${pacman_packages[@]} &>/dev/null; then
        sudo -v
        yes | sudo pacman -S ${pacman_packages[@]} --noconfirm \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Download and install dioxus related tools"
        [[ $? -ne 0 ]] && return 1
    fi

    for cargo_package in ${cargo_packages[@]}
    do
        cargo install $cargo_package \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Download and compile: '$cargo_package' with cargo"
        [[ $? -ne 0 ]] && return 1
    done

    return 0
}
remove_setup_rust_dioxus()
{
    if ! command -v cargo &>/dev/null
    then
        printf "\n\e[31m%s\e[0m\n" \
            "[!] cargo not installed, try running \`arch install rust\` first"
        return 1
    fi

    cargo_packages=(dioxus-cli)

    installed_cargo_packages="$(\
        cargo install --list | grep '^[a-z]' | awk '{print $1}'\
    )"

    for cargo_package in ${cargo_packages[@]}
    do
        if echo "$installed_cargo_packages" \
            | grep "^$cargo_package$" &>/dev/null
        then
            cargo uninstall ${cargo_package[@]} \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Uninstall cargo package: '$cargo_package'"
            [[ $? -ne 0 ]] && return 1
        fi
    done

    return 0
}
