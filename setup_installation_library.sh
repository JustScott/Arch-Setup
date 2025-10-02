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

enforce_library_files_exist() {
    if ! [[ -f "./$PRETTY_OUTPUT_LIBRARY" ]]
    then
        echo -e "\n - Missing pretty output script. Cannot Proceed - \n"
        exit 4
    fi
}

enforce_library_files_exist

setup_qemu() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    packages=(
        gnome-boxes virt-manager virt-viewer \
        qemu-emulators-full spice-vdagent swtpm \
    )

    if ! pacman -Q ${packages[@]} &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Sy --noconfirm ${packages[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Installing qemu packages"
        [[ $? -ne 0 ]] && return 1 

        sudo chmod g+rwx -R /dev/bus/usb

        {
            cat /etc/libvirt/libvirtd.conf | grep 'unix_sock_group = libvirt' &>/dev/null || \
                sudo bash -c 'echo -e "\nunix_sock_group = libvirt" >> /etc/libvirt/libvirtd.conf'
            cat /etc/libvirt/libvirtd.conf | grep 'unix_sock_rw_perms = 0770' &>/dev/null || \
                sudo bash -c 'echo "unix_sock_rw_perms = 0770" >> /etc/libvirt/libvirtd.conf'
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Alter config files"
        [[ $? -ne 0 ]] && exit 1

        if ! groups | grep "libvirt" &>/dev/null
        then
            sudo usermod -aG libvirt $USER \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Add '$USER' to 'libvirt' group"
            [[ $? -ne 0 ]] && return 1
        fi
        cat /etc/libvirt/qemu.conf | grep "group=$CURRENT_USER" &>/dev/null || \
            sudo bash -c "echo 'group=$CURRENT_USER' >> /etc/libvirt/qemu.conf"
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "rust already installed"
    fi

    if ! { which yay || type yay; } &>/dev/null
    then
        git clone https://aur.archlinux.org/yay.git \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Clone yay from the AUR"
        [[ $? -ne 0 ]] && {
            rm -rf yay
            exit 1
        }

        {
            cd yay >/dev/null 2>>/tmp/archsetuperrors.log
            makepkg -si PKGBUILD --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Install yay with makepkg"
        [[ $? -ne 0 ]] && {
            cd ..
            rm -rf yay
            exit 1
        }
        cd ..
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "yay already installed"
    fi

    return 0
}
unsetup_qemu() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    if pacman -Q yay &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Rs --noconfirm yay \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Uninstalling yay"
        [[ $? -ne 0 ]] && return 1 
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "yay not installed"
    fi

    return 0
}
