#!/bin/bash
#
# secure.sh - part of the Arch-Setup project
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


#
# Install and configure security tools to harden the system
#

ACTION="Deny access after 6 incorrect password attempts instead of 3" # Because its annoying
sudo bash -c "echo 'deny = 6' >> /etc/security/faillock.conf" &>/dev/null \
    && "[SUCCESS] $ACTION" \
    || "[FAIL] $ACTION"

ACTION="Disable root login"
sudo passwd --lock root &>/dev/null \
    && "[SUCCESS] $ACTION" \
    || "[FAIL] $ACTION"

ACTION="Disable root login over ssh"
sudo bash -c "echo 'PermitRootLogin no' >> /etc/ssh/sshd_config.d/*-archlinux.conf"
    && "[SUCCESS] $ACTION" \
    || "[FAIL] $ACTION"

ACTION="Update the CPU microcode to avoid vulnerabilities"
sudo pacman -Sy intel-ucode --noconfirm &>/dev/null && sudo grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null \
    && "[SUCCESS] $ACTION" \
    || "[FAIL] $ACTION"


ACTION="Enable the firewall and deny all incoming traffic"
{
    sudo pacman -Sy ufw --noconfirm \
    && sudo systemctl enable --now ufw \
    && sudo ufw enable \
    && sudo ufw default deny incoming
} && "[SUCCESS] $ACTION" || "[FAIL] $ACTION"
