#!/bin/bash
#
# qemu.sh - part of the Arch-Setup project
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

# Allows for mounting USB media to the virtual machines
sudo chmod g+rwx -R /dev/bus/usb

sudo pacman -Sy \
    gnome-boxes virt-manager \
    qemu-emulators-full spice-vdagent --noconfirm

sudo bash -c 'echo -e "\nunix_sock_group = "libvirt"" >> /etc/libvirt/libvirtd.conf'
sudo bash -c 'echo "unix_sock_rw_perms = "0770"" >> /etc/libvirt/libvirtd.conf'

sudo usermod -aG libvirt $USER

sudo bash -c 'echo "group="$USER"" >> /etc/libvirt/qemu.conf'

