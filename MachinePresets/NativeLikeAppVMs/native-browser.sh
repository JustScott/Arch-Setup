#!/bin/bash
#
# native-browser.sh - part of the Arch-Setup project
# Copyright (C) 2024-2025, JustScott, development@justscott.me
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
# AUTOLOGIN replacement using sed is broken, even though manual replacement works
#  and the hashes are the same wether using sed or doing it manually
#
# Autologin (user must not have a password)
#  https://unix.stackexchange.com/questions/42359/how-can-i-autologin-to-desktop-with-systemd#289612
#[[ -f "/etc/systemd/system/getty.target.wants/getty@tty1.service" ]] && {
#    # serial-getty\@ttyS0.service
#    #ExecStart=-/sbin/agetty -a lynx --keep-baud 115200,57600,38400,9600 - $TERM
#    sudo sed -i "/^ExecStart/c\ExecStart=-/sbin/agetty -a $USER --noclear - \$TERM" \
#        /etc/systemd/system/getty.target.wants/getty@tty1.service
#}

if ! [[ $(basename "$PWD") == "NativeLikeAppVMs" ]]
then
    echo "Must be in the Arch-Setup/MachinePresets/NativeLikeAppVMs directory to run this script!"
    exit 1
fi

# Open librewolf at the same time as dwm
grep "exec dwm" $HOME/.xinitrc &>/dev/null && {
    sed -i "/^exec dwm/c\exec dwm & librewolf" $HOME/.xinitrc
}

cd ..
bash browser.sh
