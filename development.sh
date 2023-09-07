#!/bin/bash
#
# development.sh - part of the Arch-Setup project
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
# For installation and configuration of development specific
#  packages
#

sudo pacman -Sy caddy python python-pip docker docker-compose --noconfirm

#
# Configure docker
#
sudo systemctl enable --now docker # start the docker service

sudo usermod -aG docker $USER # Add the current user to the docker group
