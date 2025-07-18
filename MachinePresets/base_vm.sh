#!/bin/bash
#
# base_vm.sh - part of the Arch-Setup project
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


# SOURCE: https://serverfault.com/questions/364895/virsh-vm-console-does-not-show-any-output#365007

if [[ $(basename $PWD) != "MachinePresets" ]]
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup/MachinePresets directory"
    exit 1
fi

source ../shared_lib

sudo -v

bash base.sh

# If in a QEMU virtual machine
if [[ $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null) == "QEMU" ]]
then
    original_grub_file_hash=$(sha1sum /etc/default/grub)

    # skip if the line is already in /etc/default/grub
    if ! grep 'GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0"' /etc/default/grub >/dev/null 2>>/tmp/archsetuperrors.log
    then
        # replace the line if exists, otherwise append it
        if grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub >/dev/null 2>>/tmp/archsetuperrors.log
        then
            sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/c\GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0"' \
                /etc/default/grub >/dev/null 2>>/tmp/archsetuperrors.log
        else
            sudo bash -c 'echo -e "\nGRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0"" >> /etc/default/grub' \
                >/dev/null 2>>/tmp/archsetuperrors.log
        fi
    fi
    # skip if the line is already in /etc/default/grub
    if ! grep 'GRUB_TERMINAL="serial console"' /etc/default/grub >/dev/null 2>>/tmp/archsetuperrors.log
    then
        # replace the line if exists, otherwise append it
        if grep "GRUB_TERMINAL" /etc/default/grub >/dev/null 2>>/tmp/archsetuperrors.log
        then
            sudo sed -i '/^GRUB_TERMINAL/c\GRUB_TERMINAL="serial console"' \
                /etc/default/grub >/dev/null 2>>/tmp/archsetuperrors.log
        else
            sudo bash -c 'echo -e "\nGRUB_TERMINAL="serial console"" >> /etc/default/grub' \
                >/dev/null 2>>/tmp/archsetuperrors.log
        fi
    fi

    if [[ "$original_grub_file_hash" == "$(sha1sum /etc/default/grub)" ]]
    then
        sudo grub-mkconfig -o /boot/grub/grub.cfg >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Remake grub config to allow VM serial access"
        [[ $? -ne 0 ]] && exit 1
    fi

    systemctl status serial-getty@ttyS0 &>/dev/null \
        || sudo systemctl enable --now serial-getty@ttyS0
fi
