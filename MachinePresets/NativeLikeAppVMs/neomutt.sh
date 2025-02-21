#!/bin/bash
#
# neomutt.sh - part of the Arch-Setup project
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

if [[ $(basename $PWD) != "NativeLikeAppVMs" ]]
then
    printf "\e[31m%s\e[0m\n" \
        "[Error] Please run script from the Arch-Setup/MachinePresets/NativeLikeAppVMs directory"
    exit 1
fi

source ../../shared_lib

STARTING_PWD=$PWD

cd ..
bash base_vm.sh
cd ..
bash aur.sh

packages=(
    neomutt curl isync \
    msmtp pass ca-certificates \
    gettext lynx
)

if ! pacman -Q ${packages[@]} &>/dev/null
then
    ACTION=""
    echo -n "...$ACTION..."
    sudo pacman -Sy --noconfirm ${packages[@]} \
        >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" \
        "Download and install neomutt & its dependencies"
    [[ $? -ne 0 ]] && exit 1
fi


[[ -d $HOME/pam-gnupg ]] || {
    cd $HOME
    git clone https://aur.archlinux.org/pam-gnupg.git \
        >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Clone pam-gnupg"
    [[ $? -ne 0 ]] && exit 1
    cd pam-gnupg
    makepkg -si --noconfirm >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Make pam-gnupg"
    [[ $? -ne 0 ]] && exit 1
} 

[[ -d $HOME/mutt-wizard ]] || {
    cd $HOME
    git clone https://github.com/LukeSmithxyz/mutt-wizard \
        >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Clone mutt-wizard"
    [[ $? -ne 0 ]] && exit 1
    cd mutt-wizard
    sudo make install >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
    task_output $! "$STDERR_LOG_PATH" "Install mutt-wizard"
    [[ $? -ne 0 ]] && exit 1
}

grep "neomutt" $HOME/.bash_profile &>/dev/null \
    || echo -e "\nneomutt" >> $HOME/.bash_profile

cd $STARTING_PWD

#SOURCE: https://github.com/LukeSmithxyz/mutt-wizard/issues/981

# yay -Q sentry-native &>/dev/null || yay -Sy --noconfirm sentry-native

# yay -Q protonmail-bridge &>/dev/null || yay -Sy --noconfirm protonmail-bridge

# gpg --full-gen-key
# pass init <email>
# protonmail-bridge-core --cli
    # login
    # info
#  127.0.0.1 to avoid error messages
# mw -a <email> -x "<passwd>" -i 127.0.0.1 -I 1143 -s localhost -S 1025 -f

# $HOME/.mbsyncrc
#
# SSLType None

# $HOME/.config/msmtp/config
#
# tls off
# tls_starttls off
# auth plain

#Make this an alias?
# 
# pass insert <email>
# mbysnc <email>

# ~/.config/mutt/accounts/<email>.muttrc
#  mailboxes "=INBOX" "=Folders/ChildFolder" "=Folders/ParentFolder/ChildFolder" "=Folders/ParentFolder/ChildFolder2"
# Folders are in ~/.local/share/mail/<email>/

#Reorder Accounts
# mv -r

# ~/.bash_profile
#  pass ls <email>@protonmail.com >/dev/null
#  protonmail-bridge-core --noninteractive &>/tmp/proton.log &
#  sleep 5
#  neomutt
#
