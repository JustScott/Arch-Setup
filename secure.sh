#!/bin/bash
#
# secure.sh - part of the Arch-Setup project
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

#
# Harden the system
#

if [[ $(basename $PWD) != "Arch-Setup" ]]
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup base directory"
    exit 1
fi

source ./shared_lib

sudo -v

# Because its annoying
if ! grep "deny = 6" /etc/security/faillock.conf &>/dev/null; then
    sudo bash -c "echo 'deny = 6' >> /etc/security/faillock.conf" \
        >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" \
        "Change max login attempts to 6 before lock out (because 3 was annoying)"
    [[ $? -ne 0 ]] && exit 1
fi

sudo passwd --lock root >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Disable root login"
[[ $? -ne 0 ]] && exit 1

if [[ -d /etc/ssh/ ]]; then
    if ! grep "PermitRootLogin no" /etc/ssh/sshd_config.d/*.conf &>/dev/null
    then
        sudo bash -c "echo 'PermitRootLogin no' >> /etc/ssh/sshd_config.d/*.conf" \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Disable root login over ssh"
        [[ $? -ne 0 ]] && exit 1
    fi
fi

packages=()

cpu_vendor=$(lscpu | awk '/Vendor ID/ {print $3}')
echo "$cpu_vendor" | grep -i "amd" &>/dev/null \
    && packages+=(amd-ucode)
echo "$cpu_vendor" | grep -i "intel" &>/dev/null \
    && packages+=(intel-ucode)

{
    sudo pacman -Sy ${packages[@]} --noconfirm
    sudo grub-mkconfig -o /boot/grub/grub.cfg
} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Update the CPU microcode to avoid vulnerabilities"
[[ $? -ne 0 ]] && exit 1

# Leaving this commented here as reference for if I create a firewall script
#
#ACTION="Install and Enable the firewall, then deny all incoming traffic"
#echo -n "...$ACTION..."
#sudo pacman -Sy ufw --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log \
#    && sudo systemctl enable --now ufw >/dev/null 2>>/tmp/archsetuperrors.log \
#    && sudo ufw enable >/dev/null 2>>/tmp/archsetuperrors.log \
#    && sudo ufw default deny incoming >/dev/null 2>>/tmp/archsetuperrors.log \
#        && echo "[SUCCESS]" \
#        || echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"
