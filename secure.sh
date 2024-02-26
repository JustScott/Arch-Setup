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

ACTION="Deny access temporarily after 6 incorrect password attempts instead of 3" # Because its annoying
sudo bash -c "echo 'deny = 6' >> /etc/security/faillock.conf" >/dev/null 2>>~/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"

ACTION="Disable root login"
sudo passwd --lock root >/dev/null 2>>~/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"

ACTION="Disable root login over ssh"
[[ -d /etc/ssh/ ]] && {
    sudo bash -c "echo 'PermitRootLogin no' >> /etc/ssh/sshd_config.d/*.conf" >/dev/null 2>>~/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"
}

ACTION="Update the CPU microcode to avoid vulnerabilities" >/dev/null 2>>~/archsetuperrors.log
echo "...$ACTION..."
sudo pacman -Sy intel-ucode --noconfirm &>/dev/null && sudo grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>>~/archsetuperrors.log \
    && echo "[SUCCESS] $ACTION" \
    || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"

ACTION="Install and Enable the firewall, then deny all incoming traffic"
echo "...$ACTION..."
sudo pacman -Sy ufw --noconfirm >/dev/null 2>>~/archsetuperrors.log \
    && sudo systemctl enable --now ufw >/dev/null 2>>~/archsetuperrors.log \
    && sudo ufw enable >/dev/null 2>>~/archsetuperrors.log \
    && sudo ufw default deny incoming >/dev/null 2>>~/archsetuperrors.log \
        && echo "[SUCCESS] $ACTION" \
        || echo "[FAIL] $ACTION... wrote error log to ~/archsetuperrors.log"
