#!/bin/bash
#
# flutter_development.sh - part of the Arch-Setup project
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

SCRIPT_DIR=../NonUserRunnable/backup_scripts/flutter_development

mkdir -p ~/.scripts/general
sudo ln -sf $PWD/$SCRIPT_DIR/pack /usr/local/bin/pack
sudo ln -sf $PWD/$SCRIPT_DIR/unpack /usr/local/bin/unpack


yay -Sy \
    dart android-tools flutter \
    android-studio android-sdk android-sdk-cmdline-tools-latest adb \
    clang cmake ninja base-devel --noconfirm


flutter create test_flutter_app 

echo -e "\n------\n1. Complete the android studio prompts to continue the installation"
echo "2. Close the Android studio project page and a new one will reopen with a Flutter project that was created for you, click 'Trust Project'"
echo "3. Go to file -> settings -> Android SDK -> SDK Tools."
echo "4. Download 'Android SDK Command-line Tools (latest)' by checking the box and clicking apply."
echo -e "Exit android studio to allow the script to continue running\n------\n"

android-studio > /dev/null 2>&1

android-studio test_flutter_app > /dev/null 2>&1  

# Suppresses an error
git config --global --add safe.directory /opt/flutter

flutter doctor --android-licenses

flutter config --android-sdk ~/Android/Sdk

rm -rf test_flutter_app
