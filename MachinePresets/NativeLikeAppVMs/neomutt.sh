#!/bin/bash
#
# neomutt.sh - part of the Arch-Setup project
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

STARTING_PWD=$PWD

packages=(
    neomutt curl isync \
    msmtp pass ca-certificates \
    gettext
)

if ! pacman -Q ${packages[@]} &>/dev/null
then
    ACTION="Install neomutt & its dependencies"
    echo -n "...$ACTION..."
    sudo pacman -Sy --noconfirm ${packages[@]} >/dev/null 2>>/tmp/archsetuperrors.log \
        && echo "[SUCCESS]" \
        || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit; }
fi


[[ -d $HOME/pam-gnupg ]] || {
    cd $HOME
    git clone https://aur.archlinux.org/pam-gnupg.git
    cd pam-gnupg
    makepkg -si --noconfirm
}

[[ -d $HOME/mutt-wizard ]] || {
    cd $HOME
    git clone https://github.com/LukeSmithxyz/mutt-wizard
    cd mutt-wizard
    sudo make install
}

grep "neomutt" $HOME/.bash_profile &>/dev/null \
    || echo -e "\nneomutt" >> $HOME/.bash_profile

if ! { which yay || type yay; } &>/dev/null
then
    ACTION="Clone, compile, and install yay from the AUR (this may take a while)"
    echo -n "...$ACTION..."
    cd # pwd -> $HOME
    if git clone https://aur.archlinux.org/yay.git >/dev/null 2>>/tmp/archsetuperrors.log
    then
        {
            cd yay >/dev/null 2>>/tmp/archsetuperrors.log
            makepkg -si PKGBUILD --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log
            cd $VIRTUAL_MACHINES_PWD
        } >/dev/null 2>>/tmp/archsetuperrors.log \
            && echo "[SUCCESS]" \
            || { echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"; exit; }
    else
        echo "[FAIL] wrote error log to /tmp/archsetuperrors.log"
        exit 1
    fi
fi


# SOURCE: https://github.com/LukeSmithxyz/mutt-wizard/issues/981

#yay -Q sentry-native &>/dev/null || yay -Sy --noconfirm sentry-native

#yay -Q protonmail-bridge &>/dev/null || yay -Sy --noconfirm protonmail-bridge

# gpg --full-gen-key
# pass init <email>
# protonmail-bridge-core --cli
    # login
    # info
# mw -a <email> -x "<passwd>" -i localhost -I 1143 -s localhost -S 1025 -f

# $HOME/.mbsyncrc
#
# SSLType None

# $HOME/.config/msmtp/config
#
# tls off
# tls_starttls off
# auth plain

#  Make this an alias?
# protonmail-bridge-core --noninteractive &>/tmp/proton.log &

# pass insert <email>
# mbysnc <email>


cd $STARTING_PWD

cd ..
bash base_vm.sh
