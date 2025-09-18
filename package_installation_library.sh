#!/bin/bash
#
# package_installation_library.sh - part of the Arch-Setup project
# Copyright (C) 2025, JustScott, development@justscott.me
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

PRETTY_OUTPUT_LIBRARY=pretty_output_library.sh

enforce_library_files_exist() {
    if ! [[ -f "./$PRETTY_OUTPUT_LIBRARY" ]]
    then
        echo -e "\n - Missing pretty output script. Cannot Proceed - \n"
        exit 4
    fi
}

enforce_library_files_exist

install_yay() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    if ! { which yay || type yay; } &>/dev/null
    then
        git clone https://aur.archlinux.org/yay.git \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Clone yay from the AUR"
        [[ $? -ne 0 ]] && {
            rm -rf yay
            exit 1
        }

        {
            cd yay >/dev/null 2>>/tmp/archsetuperrors.log
            makepkg -si PKGBUILD --noconfirm >/dev/null 2>>/tmp/archsetuperrors.log
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Install yay with makepkg"
        [[ $? -ne 0 ]] && {
            cd ..
            rm -rf yay
            exit 1
        }
        cd ..
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "yay already installed"
    fi

    return 0
}
uninstall_yay() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    if pacman -Q yay &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Rs --noconfirm yay \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Uninstalling yay"
        [[ $? -ne 0 ]] && return 1 
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "yay not installed"
    fi

    return 0
}

install_qutebrowser() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    if ! pacman -Q qutebrowser &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Sy --noconfirm qutebrowser \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Installing qutebrowser"
        [[ $? -ne 0 ]] && return 1 
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "qutebrowser already installed"
    fi

    return 0
}
uninstall_qutebrowser() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    if pacman -Q qutebrowser &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Rs --noconfirm qutebrowser \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Uninstalling qutebrowser"
        [[ $? -ne 0 ]] && return 1 
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "qutebrowser not installed"
    fi

    return 0
}

install_librewolf() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    if ! { which yay || type yay; } &>/dev/null
    then
        printf "\n\r\e[31m[Error]\e[0m %s\n" "yay must be installed first as librewolf is only available in the aur"
        exit 5
    fi

    if ! yay -Q librewolf &>/dev/null
    then
        sudo -v
        yes | yay -Sy --noconfirm librewolf \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Installing librewolf"
        [[ $? -ne 0 ]] && return 1 
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "librewolf already installed"
    fi

    return 0
}
uninstall_librewolf() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    if ! { which yay || type yay; } &>/dev/null
    then
        printf "\n\r\e[31m[Error]\e[0m %s\n" "Cannot uninstall librewolf without yay being installed, as yay manages aur packages"
        exit 5
    fi

    if yay -Q librewolf &>/dev/null
    then
        sudo -v
        yes | yay -Rs --noconfirm librewolf \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Uninstalling librewolf"
        [[ $? -ne 0 ]] && return 1 
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "librewolf not installed"
    fi

    return 0
}

install_docker() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    local packages

    packages=(docker docker-compose)

    if ! pacman -Q ${packages[@]} &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Sy --noconfirm ${packages[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Installing docker"
        [[ $? -ne 0 ]] && return 1 

        if ! systemctl is-enabled docker &>/dev/null
        then
            sudo -v
            sudo systemctl enable docker \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Enable the docker service"
            [[ $? -ne 0 ]] && exit 1
        fi

        if ! systemctl is-active docker &>/dev/null
        then
            sudo -v
            sudo systemctl start docker \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Start the docker service"
            [[ $? -ne 0 ]] && exit 1
        fi
        
        if ! groups $USER | grep "docker" &>/dev/null
        then
            sudo -v
            sudo usermod -aG docker $USER \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Add '$USER' to the 'docker' group"
            [[ $? -ne 0 ]] && exit 1
        fi

        if [[ -f $HOME/.bashrc ]]; then
            {
                cat $HOME/.bashrc | grep "export DOCKER_BUILDKIT=1" &>/dev/null || \
                    echo -e "\nexport DOCKER_BUILDKIT=1" >> $HOME/.bashrc
                cat $HOME/.bashrc | grep "export COMPOSE_DOCKER_CLI_BUILD=1" &>/dev/null || \
                    echo -e "export COMPOSE_DOCKER_CLI_BUILD=1\n" >> $HOME/.bashrc
            } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Append docker variables to .bashrc if needed"
            [[ $? -ne 0 ]] && exit 1
        fi
    else
        printf "\r\e[33m[skipping...]\e[0m %s" "docker already already installed"
    fi

    return 0
}
uninstall_docker() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    packages=(docker docker-compose)

    if systemctl is-active docker &>/dev/null
    then
        sudo -v
        sudo systemctl stop docker \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Stop the docker service"
        [[ $? -ne 0 ]] && exit 1
    fi
    if systemctl is-enabled docker &>/dev/null
    then
        sudo -v
        sudo systemctl disable docker \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Disable the docker service"
        [[ $? -ne 0 ]] && exit 1
    fi

    if groups $USER | grep "docker" &>/dev/null
        then
            sudo -v
            sudo usermod -rG docker $USER \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Remove '$USER' from the 'docker' group"
            [[ $? -ne 0 ]] && exit 1
        fi

    if pacman -Q ${packages[@]} &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Rs --noconfirm ${packages[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Uninstalling docker"
        [[ $? -ne 0 ]] && return 1 
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "docker not installed"
    fi
     
    if cat $HOME/.bashrc | grep "export COMPOSE_DOCKER_CLI_BUILD=" &>/dev/null
    then
        sed -i '/export COMPOSE_DOCKER_CLI_BUILD=/d' $HOME/.bashrc \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Remove docker cli build variable from .bashrc"
        [[ $? -ne 0 ]] && return 1
    fi

    if cat $HOME/.bashrc | grep "export DOCKER_BUILDKIT=" &>/dev/null
    then
        sed -i '/export DOCKER_BUILDKIT=/d' $HOME/.bashrc \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Remove docker buildkit variable from .bashrc"
        [[ $? -ne 0 ]] && return 1
    fi

    return 0
}

install_python() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    packages=(python python-pip)

    if ! pacman -Q ${packages[@]} &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Sy --noconfirm ${packages[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Installing python"
        [[ $? -ne 0 ]] && return 1 
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "python already installed"
    fi

    return 0
}
uninstall_python() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    packages=(python python-pip)

    if pacman -Q ${packages[@]} &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Rs --noconfirm ${packages[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Uninstalling python"
        [[ $? -ne 0 ]] && return 1 
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "python not installed"
    fi

    return 0
}

install_rust() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    packages=(rustup)

    if ! pacman -Q ${packages[@]} &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Sy --noconfirm ${packages[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Installing rust"
        [[ $? -ne 0 ]] && return 1 
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "rust already installed"
    fi

    if rustup show | grep "no active toolchain" 
    then
        rustup default stable >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Set the default toolchain to stable"
        [[ $? -ne 0 ]] && exit 1
    fi

    if ! cat $HOME/.bashrc | grep "export PATH=\"\$PATH:\$HOME/.cargo/bin\"" &>/dev/null
    then
        echo -e "\nexport PATH=\"\$PATH:\$HOME/.cargo/bin\"" >> $HOME/.bashrc
        task_output $! "$STDERR_LOG_PATH" "Add cargo binaries to PATH (in .bashrc)"
        [[ $? -ne 0 ]] && exit 1
    fi

    return 0
}
uninstall_rust() {
    source ./$PRETTY_OUTPUT_LIBRARY || enforce_library_files_exist

    packages=(rustup)

    if pacman -Q ${packages[@]} &>/dev/null
    then
        sudo -v
        yes | sudo pacman -Rs --noconfirm ${packages[@]} \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Uninstalling rust"
        [[ $? -ne 0 ]] && return 1 
    else
        printf "\r\e[33m[skipping...]\e[0m %s\n" "rust not installed"
    fi


    if cat $HOME/.bashrc | grep "export PATH=\"\$PATH:\$HOME/.cargo/bin\"" &>/dev/null
    then
        sed -i '/export PATH="$PATH:$HOME\/.cargo\/bin"/d' $HOME/.bashrc
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Remove cargo binaries from PATH (in .bashrc)"
        [[ $? -ne 0 ]] && return 1 
    fi

    return 0
}
