#!/bin/bash
#
# dioxus.sh - part of the Arch-Setup project
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

CURRENT_PWD="$PWD"
cd ..
bash aur.sh
bash qemu.sh

cd $CURRENT_PWD
bash development.sh

packages=( \
    android-ndk android-sdk android-sdk-build-tools android-sdk-cmdline-tools-latest \
    sdkmanager android-sdk-platform-tools android-tools android-platform android-emulator \
    jdk21-openjdk webkit2gtk-4.1 base-devel curl wget file openssl appmenu-gtk-module \
    libappindicator-gtk3 librsvg xdotool \
)

echo -e "\n-----------------------\n| Packages To Install |\n-----------------------\n\n${packages[@]}\n\n"

if ! yay -Q ${packages[@]} &>/dev/null; then
    ACTION="Install Dioxus development packages"
    echo -n "...$ACTION..."
    yay -Sy ${packages[@]} --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log\
        && echo "[SUCCESS]" \
        || echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"
fi

ACTION="Install dioxus-cli (This might take a while)"
echo -n "...$ACTION..."
echo cargo install dioxus-cli >/dev/null 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS]" \
    || echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"

ACTION="Add cargo binaries to system path"
echo -n "...$ACTION..."
echo "export PATH=\"\$PATH:/home/$USER/.cargo/bin\"" >> $HOME/.bashrc 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS]" \
    || echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"

ACTION="Add the android-sdk to Path"
echo -n "...$ACTION..."
{
    export ANDROID_NDK_HOME=/opt/android-ndk
    export ANDROID_HOME=/opt/android-sdk
    export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
    export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
    export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
    export PATH=$PATH:$JAVA_HOME/bin
} >/dev/null 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS]" \
    || echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"

ACTION="Add android build targets with rustup"
echo -n "...$ACTION..."
rustup target add aarch64-linux-android armv7-linux-androideabi \
    i686-linux-android x86_64-linux-android >> $HOME/.bashrc 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS]" \
    || echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"

ACTION="Create android-sdk group"
echo -n "...$ACTION..."
{
    sudo groupadd android-sdk
    sudo gpasswd -a $USER android-sdk
    sudo setfacl -R -m g:android-sdk:rwx /opt/android-sdk
    sudo setfacl -d -m g:android-sdk:rwX /opt/android-sdk  
} >/dev/null 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS]" \
    || echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"

newgrp libvirt android-sdk <<EOF
ACTION="Accept Android SDK Licenses"
echo -n "...$ACTION..."
yes | sdkmanager --licenses >/dev/null 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS]" \
    || echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"

ACTION="Install & Set-up emulator with qemu"
echo -n "...$ACTION..."
{
    yes | sdkmanager "system-images;android-30;default;x86_64"
    sdkmanager "emulator"
} >/dev/null 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS]" \
    || echo "[FAIL] wrote error log to /tmp/arThsetuperrors.log"

ACTION="Set system java version to java-21-openjdk"
echo -n "...$ACTION..."
sudo archlinux-java set java-21-openjdk >/dev/null 2>>/tmp/archsetuperrors.log \
    && echo "[SUCCESS]" \
    || echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"

cd ..
bash gnome.sh
EOF


# avdmanager create avd -n new_avd -k "system-images;android-30;default;x86_64"
# emulator -avd new_avd
