#!/bin/bash
#
# qemu.sh - part of the Arch-Setup project
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

if [[ $(basename $PWD) != "Arch-Setup" ]]
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup base directory"
    exit 1
fi

source ./shared_lib

# Allows for mounting USB media to the virtual machines
sudo chmod g+rwx -R /dev/bus/usb

packages=(
    gnome-boxes virt-manager virt-viewer \
    qemu-emulators-full spice-vdagent
)

if ! pacman -Q ${packages[@]} &>/dev/null; then
    sudo pacman -Sy ${packages[@]} --noconfirm \
        >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Download and install QEMU related packages with pacman"
    [[ $? -ne 0 ]] && exit 1
fi


{
    cat /etc/libvirt/libvirtd.conf | grep 'unix_sock_group = libvirt' &>/dev/null || \
        sudo bash -c 'echo -e "\nunix_sock_group = libvirt" >> /etc/libvirt/libvirtd.conf'
    cat /etc/libvirt/libvirtd.conf | grep 'unix_sock_rw_perms = 0770' &>/dev/null || \
        sudo bash -c 'echo "unix_sock_rw_perms = 0770" >> /etc/libvirt/libvirtd.conf'
    CURRENT_USER=$USER # Must set this since $USER in the echo command below will be ran by root
    groups | grep "libvirt" &>/dev/null || \
        sudo usermod -aG libvirt $CURRENT_USER
    cat /etc/libvirt/qemu.conf | grep "group=$CURRENT_USER" &>/dev/null || \
        sudo bash -c "echo 'group=$CURRENT_USER' >> /etc/libvirt/qemu.conf"
} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Configure QEMU"
[[ $? -ne 0 ]] && exit 1
