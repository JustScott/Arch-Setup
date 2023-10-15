#!/bin/bash
#
# user.sh - part of the Arch-Setup project
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
# Helpful aliased bash commands
#

echo -e 'export EDITOR=nvim\n' >> ~/.bashrc
echo "alias batt='cat /sys/class/power_supply/BAT0/capacity'" >> ~/.bashrc
echo "alias admin='su administrator -P -c'" >> ~/.bashrc
echo "alias space='df -h /'" >> ~/.bashrc
echo "alias up='ping quad9.net -c 4'" >> ~/.bashrc
echo 'alias swapc='"'"'su - administrator -P -c "sudo swapoff -a;sleep 2;sudo swapon -a"'"'" >> ~/.bashrc
