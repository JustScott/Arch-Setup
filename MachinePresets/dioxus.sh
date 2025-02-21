#!/bin/bash
#
# dioxus.sh - part of the Arch-Setup project
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

if [[ $(basename $PWD) != "MachinePresets" ]]
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup/MachinePresets directory"
    exit 1
fi

source ../shared_lib

cd ..
bash aur.sh
bash qemu.sh
bash secure.sh

cd Development
bash rust.sh

packages=( \
    android-ndk android-sdk android-sdk-build-tools android-sdk-cmdline-tools-latest \
    android-sdk-platform-tools android-tools android-platform android-emulator \
    jdk21-openjdk webkit2gtk-4.1 base-devel curl wget file openssl appmenu-gtk-module \
    libappindicator-gtk3 librsvg xdotool libbsd \
)

echo -e "\n-----------------------\n| Packages To Install |\n-----------------------\n\n${packages[@]}\n\n"

if ! yay -Q ${packages[@]} &>/dev/null; then
    yay -Sy ${packages[@]} --noconfirm >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Install Dioxus development packages"
    [[ $? -ne 0 ]] && exit 1
fi

cargo install dioxus-cli --noconfirm >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" \
    "Download and compile dioxus-cli (this may take awhile)"
[[ $? -ne 0 ]] && exit 1

echo "export PATH=\"\$PATH:/home/$USER/.cargo/bin\"" \
    >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Add cargo binaries to system path"
[[ $? -ne 0 ]] && exit 1

{
    cat $HOME/.bashrc | grep "export ANDROID_NDK_HOME=/opt/android-ndk" &>/dev/null || \
        echo "export ANDROID_NDK_HOME=/opt/android-ndk" >> $HOME/.bashrc
    cat $HOME/.bashrc | grep "ANDROID_HOME=/opt/android-sdk" &>/dev/null || \
        echo "export ANDROID_HOME=/opt/android-sdk" >> $HOME/.bashrc
    cat $HOME/.bashrc | grep "PATH=\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/platform-tools" &>/dev/null || \
        echo "export PATH=\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/platform-tools" >> $HOME/.bashrc
    cat $HOME/.bashrc | grep "PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin" &>/dev/null || \
        echo "export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin" >> $HOME/.bashrc
    cat $HOME/.bashrc | grep "JAVA_HOME=/usr/lib/jvm/java-21-openjdk" &>/dev/null || \
        echo "export JAVA_HOME=/usr/lib/jvm/java-21-openjdk" >> $HOME/.bashrc
    cat $HOME/.bashrc | grep "PATH=\$PATH:\$JAVA_HOME/bin" &>/dev/null || \
        echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> $HOME/.bashrc
} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Add the android-sdk to Path"
    [[ $? -ne 0 ]] && exit 1

rustup target add aarch64-linux-android armv7-linux-androideabi \
    i686-linux-android x86_64-linux-android \
    >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Add android build targets with rustup"
[[ $? -ne 0 ]] && exit 1

{
    sudo groupadd android-sdk
    sudo gpasswd -a $USER android-sdk
    sudo chown -R :android-sdk /opt/android-sdk
    sudo chmod -R g+rwx /opt/android-sdk
#    sudo setfacl -R -m g:android-sdk:rwx /opt/android-sdk
#    sudo setfacl -d -m g:android-sdk:rwX /opt/android-sdk
} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Create android-sdk group"
[[ $? -ne 0 ]] && exit 1

newgrp android-sdk <<EOF
if ! [[ $(basename $PWD) != "MachinePresets" ]] &>/dev/null
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup/Development directory"
    exit 1
fi

source ../shared_lib

yes | sdkmanager --licenses >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Accept Android SDK Licenses"
[[ $? -ne 0 ]] && exit 1

{
    yes | sdkmanager "system-images;android-30;default;x86_64"
    sdkmanager "emulator"
} >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Install & Set-up emulator with qemu"
[[ $? -ne 0 ]] && exit 1

sudo archlinux-java set java-21-openjdk >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
task_output $! "$STDERR_LOG_PATH" "Set system java version to java-21-openjdk"
[[ $? -ne 0 ]] && exit 1

cd ..
EOF


# avdmanager create avd -n new_avd -k "system-images;android-30;default;x86_64"
# emulator -avd new_avd
