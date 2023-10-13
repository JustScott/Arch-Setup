#!/bin/bash
#
# development_apps.sh - part of the Arch-Setup project
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

yay -Sy flatpak librewolf-bin --noconfirm

flatpak install io.github.alainm23.planify \
    com.notesnook.Notesnook -y

# Create links to the flatpak packages in a directory under $PATH
sudo ln -s /var/lib/flatpak/exports/bin/com.notesnook.Notesnook /usr/local/bin/notesnook
sudo ln -s /var/lib/flatpak/exports/bin/io.github.alainm23.planify /usr/local/bin/planify

# Make them executable by all
sudo chmod +x /usr/local/bin/{notesnook,planify}
