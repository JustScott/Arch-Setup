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
    [[ $? -ne 0 ]] && exit 1

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

    if pacman -Q ${packages[@]} &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Rs --noconfirm ${packages[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Uninstall qemu packages"
        [[ $? -ne 0 ]] && return 1 
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" \
            "No Qemu packages installed"
    fi

    if ! groups | grep "libvirt" &>/dev/null
    then
        sudo gpasswd -d $CURRENT_USER libvirt \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Remove '$CURRENT_USER' from the 'libvirt' group"
        [[ $? -ne 0 ]] && return 1
    fi
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
        [[ $? -ne 0 ]] && exit 1
    fi

    sudo passwd --lock root >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Disable root login"
    [[ $? -ne 0 ]] && exit 1

    if ! [[ -f "$SSH_CONFIG_FILE_PATH" ]]
    then
        sudo bash -c \
            "echo 'PermitRootLogin no' >> "$SSH_CONFIG_FILE_PATH"" \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Add rule to disable root login over ssh"
        [[ $? -ne 0 ]] && exit 1

        if systemctl is-active sshd &>/dev/null
        then
            sudo systemctl reload sshd \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Reload the ssh daemon"
            [[ $? -ne 0 ]] && exit 1
        fi
    fi
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
        [[ $? -ne 0 ]] && exit 1
    fi

    sudo passwd --unlock root >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Enable root login"
    [[ $? -ne 0 ]] && exit 1

    if [[ -f "$SSH_CONFIG_FILE_PATH" ]]
    then
        sudo rm $SSH_CONFIG_FILE_PATH &>/dev/null
        task_output $! "$STDERR_LOG_PATH" \
            "Remove rule against root login over ssh"
        [[ $? -ne 0 ]] && exit 1

        if systemctl is-active sshd &>/dev/null
        then
            sudo systemctl reload sshd \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Reload the ssh daemon"
            [[ $? -ne 0 ]] && exit 1
        fi
    fi
}
