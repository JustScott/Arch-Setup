#!/bin/bash
#
# native_browser.sh - part of the Arch-Setup project
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

# Autologin (user must not have a password)
[[ -f "/etc/systemd/system/getty.target.wants/getty@tty1.service" ]] && {
    sudo sed -i "/^ExecStart/c\ExecStart=-/sbin/agetty -a $USER --noclear - \$TERM" \
        /etc/systemd/system/getty.target.wants/getty@tty1.service
}

# Open librewolf at the same time as dwm
grep "exec dwm" $HOME/.xinitrc &>/dev/null && {
    sed -i "/^exec dwm/c\exec dwm & librewolf" $HOME/.xinitrc
}

bash browser.sh
